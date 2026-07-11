import '../model/auth_response.dart';
import '../model/cliente.dart';
import '../model/direccion_cliente.dart';
import '../model/perfil_usuario.dart';

abstract class AuthRepository {
  Future<AuthResponse> login({
    required String username,
    required String password,
  });

  Future<AuthResponse> register({required Map<String, dynamic> payload});

  Future<AuthResponse> refreshToken();

  Future<PerfilUsuario> getProfile();

  Future<Cliente?> getClienteByPerfil(int perfilId);

  Future<Cliente> saveCliente(Cliente cliente);

  Future<DireccionCliente?> getDireccionByCliente(int clienteId);

  Future<DireccionCliente> saveDireccion(DireccionCliente direccion);

  Future<void> logout();

  Future<String?> getAccessToken();
}
