import '../../domain/model/auth_response.dart';
import '../../domain/model/perfil_usuario.dart';
import '../../domain/repository/auth_repository.dart';
import '../local/secure_storage.dart';
import '../remote/api/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SecureStorage secureStorage,
  })  : _remote = remote,
        _secureStorage = secureStorage;

  final AuthRemoteDataSource _remote;
  final SecureStorage _secureStorage;

  @override
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final auth = await _remote.login(username: username, password: password);
    await _secureStorage.saveTokens(
      accessToken: auth.access,
      refreshToken: auth.refresh,
    );
    return auth;
  }

  @override
  Future<AuthResponse> register({required Map<String, dynamic> payload}) async {
    final auth = await _remote.register(payload: payload);
    await _secureStorage.saveTokens(
      accessToken: auth.access,
      refreshToken: auth.refresh,
    );
    return auth;
  }

  @override
  Future<AuthResponse> refreshToken() async {
    final refresh = await _secureStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      throw Exception('No refresh token available');
    }

    final auth = await _remote.refreshToken(refreshToken: refresh);
    await _secureStorage.saveTokens(
      accessToken: auth.access,
      refreshToken: auth.refresh,
    );
    return auth;
  }

  @override
  Future<PerfilUsuario> getProfile() {
    return _remote.getProfile();
  }

  @override
  Future<void> logout() {
    return _secureStorage.clearTokens();
  }

  @override
  Future<String?> getAccessToken() {
    return _secureStorage.getAccessToken();
  }
}
