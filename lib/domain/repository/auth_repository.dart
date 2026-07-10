import '../model/auth_response.dart';
import '../model/perfil_usuario.dart';

abstract class AuthRepository {
  Future<AuthResponse> login({
    required String username,
    required String password,
  });

  Future<AuthResponse> register({required Map<String, dynamic> payload});

  Future<AuthResponse> refreshToken();

  Future<PerfilUsuario> getProfile();

  Future<void> logout();

  Future<String?> getAccessToken();
}
