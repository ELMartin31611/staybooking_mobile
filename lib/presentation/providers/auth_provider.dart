import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/secure_storage.dart';
import '../../data/remote/api/auth_remote_datasource.dart';
import '../../data/remote/api/dio_client.dart';
import '../../data/remote/interceptor/auth_interceptor.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/model/perfil_usuario.dart';
import '../../domain/repository/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final PerfilUsuario? profile;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.profile,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    bool clearError = false,
    PerfilUsuario? profile,
    bool clearProfile = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: clearError ? null : (error ?? this.error),
      profile: clearProfile ? null : (profile ?? this.profile),
    );
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return const SecureStorage();
});

final authDioProvider = Provider<Dio>((ref) {
  final dio = DioClient.dio;
  final storage = ref.watch(secureStorageProvider);

  final hasInterceptor = dio.interceptors.any(
    (interceptor) => interceptor is AuthInterceptor,
  );

  if (!hasInterceptor) {
    dio.interceptors.add(
      AuthInterceptor(
        secureStorage: storage,
      ),
    );
  }

  return dio;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    dio: ref.watch(authDioProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required AuthRepository repository,
  })  : _repository = repository,
        super(
          const AuthState(
            isLoading: true,
          ),
        );

  final AuthRepository _repository;

  Future<void> bootstrap() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final token = await _repository.getAccessToken();

      if (token == null || token.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          clearProfile: true,
          clearError: true,
        );
        return;
      }

      PerfilUsuario? profile;

      try {
        profile = await _repository.getProfile();
      } catch (_) {
        try {
          await _repository.refreshToken();
          profile = await _repository.getProfile();
        } catch (_) {
          await _repository.logout();

          state = state.copyWith(
            isLoading: false,
            isAuthenticated: false,
            clearProfile: true,
            clearError: true,
          );
          return;
        }
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: profile,
        clearError: true,
      );
    } catch (error) {
      await _repository.logout();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _parseError(error),
        clearProfile: true,
      );
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isAuthenticated: false,
      clearError: true,
      clearProfile: true,
    );

    try {
      final auth = await _repository.login(
        username: username,
        password: password,
      );

      if (auth.access.trim().isEmpty || auth.refresh.trim().isEmpty) {
        await _repository.logout();

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: 'El servidor no devolvió tokens de autenticación.',
          clearProfile: true,
        );

        return false;
      }

      final profile = await _repository.getProfile();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: profile,
        clearError: true,
      );

      return true;
    } catch (error) {
      await _repository.logout();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _parseError(error),
        clearProfile: true,
      );

      return false;
    }
  }

  Future<bool> register({
    required Map<String, dynamic> payload,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isAuthenticated: false,
      clearError: true,
      clearProfile: true,
    );

    try {
      final auth = await _repository.register(
        payload: payload,
      );

      if (auth.access.trim().isEmpty || auth.refresh.trim().isEmpty) {
        await _repository.logout();

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: 'Cuenta creada. Ahora inicia sesión con tus credenciales.',
          clearProfile: true,
        );

        return false;
      }

      final profile = await _repository.getProfile();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: profile,
        clearError: true,
      );

      return true;
    } catch (error) {
      await _repository.logout();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _parseError(error),
        clearProfile: true,
      );

      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: false,
      clearProfile: true,
      clearError: true,
    );
  }

  String _parseError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map) {
        if (data['detail'] != null) {
          return data['detail'].toString();
        }

        if (data['non_field_errors'] is List &&
            (data['non_field_errors'] as List).isNotEmpty) {
          return (data['non_field_errors'] as List).first.toString();
        }

        if (data['username'] is List && (data['username'] as List).isNotEmpty) {
          return (data['username'] as List).first.toString();
        }
      }

      if (statusCode == 400 || statusCode == 401) {
        return 'Usuario o contraseña incorrectos.';
      }

      if (statusCode == 403) {
        return 'Tu usuario no tiene permiso para ingresar.';
      }

      if (statusCode != null && statusCode >= 500) {
        return 'El servidor presenta un problema. Intenta nuevamente.';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'El servidor tardó demasiado en responder.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'No se pudo conectar con el servidor.';
      }

      return 'No se pudo completar la autenticación.';
    }

    return 'Ocurrió un error inesperado.';
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    repository: ref.watch(authRepositoryProvider),
  );
});
