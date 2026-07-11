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
  final hasInterceptor =
      dio.interceptors.any((interceptor) => interceptor is AuthInterceptor);

  if (!hasInterceptor) {
    dio.interceptors.add(AuthInterceptor(secureStorage: storage));
  }

  return dio;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(authDioProvider);
  return AuthRemoteDataSource(dio: dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  AuthController({required AuthRepository repository})
      : _repository = repository,
        super(const AuthState());

  final AuthRepository _repository;

  Future<void> bootstrap() async {
    final token = await _repository.getAccessToken();
    if (token == null || token.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, clearError: true);
      PerfilUsuario? profile;
      try {
        profile = await _repository.getProfile();
      } catch (_) {
        profile = null;
      }
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: profile,
        clearProfile: profile == null,
      );
    } catch (_) {
      await _repository.logout();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        clearProfile: true,
      );
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        clearProfile: true,
      );
      await _repository.login(username: username, password: password);

      PerfilUsuario? profile;
      try {
        profile = await _repository.getProfile();
      } catch (_) {
        profile = null;
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: profile,
        clearProfile: profile == null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _parseError(e),
        clearProfile: true,
      );
      return false;
    }
  }

  Future<bool> register({required Map<String, dynamic> payload}) async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        clearProfile: true,
      );
      await _repository.register(payload: payload);

      PerfilUsuario? profile;
      try {
        profile = await _repository.getProfile();
      } catch (_) {
        profile = null;
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        profile: profile,
        clearProfile: profile == null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _parseError(e),
        clearProfile: true,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(
      isAuthenticated: false,
      clearProfile: true,
      clearError: true,
    );
  }

  String _parseError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      return 'No se pudo completar la autenticación';
    }
    return 'Error inesperado';
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(repository: ref.watch(authRepositoryProvider));
});
