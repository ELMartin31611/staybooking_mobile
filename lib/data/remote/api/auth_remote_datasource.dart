import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/auth_response.dart';
import '../../../domain/model/cliente.dart';
import '../../../domain/model/direccion_cliente.dart';
import '../../../domain/model/perfil_usuario.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
    );

    return AuthResponse.fromJson(_asMap(response.data));
  }

  Future<AuthResponse> register({required Map<String, dynamic> payload}) async {
    final response = await _dio.post(ApiEndpoints.register, data: payload);
    return AuthResponse.fromJson(_asMap(response.data));
  }

  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    final response = await _dio.post(
      ApiEndpoints.refresh,
      data: {'refresh': refreshToken},
    );

    final json = _asMap(response.data);
    return AuthResponse(
      access: (json['access'] ?? '').toString(),
      refresh: (json['refresh'] ?? refreshToken).toString(),
    );
  }

  Future<PerfilUsuario> getProfile() async {
    final response = await _dio.get(ApiEndpoints.profile);
    return PerfilUsuario.fromJson(_asMap(response.data));
  }

  Future<Cliente?> getClienteByPerfil(int perfilId) async {
    final response = await _dio.get(ApiEndpoints.clientes);
    for (final item in _asList(response.data)) {
      final map = _asMap(item);
      if (_matchesRelation(map['perfil'], perfilId)) {
        return Cliente.fromJson(map);
      }
    }
    return null;
  }

  Future<Cliente> saveCliente(Cliente cliente) async {
    final response = cliente.id == 0
        ? await _dio.post(ApiEndpoints.clientes, data: cliente.toJson())
        : await _dio.put(
            '${ApiEndpoints.clientes}${cliente.id}/',
            data: cliente.toJson(),
          );

    final raw = response.data;
    if (raw is Map) {
      return Cliente.fromJson(_asMap(raw));
    }
    return cliente;
  }

  Future<DireccionCliente?> getDireccionByCliente(int clienteId) async {
    final response = await _dio.get(ApiEndpoints.direccionesCliente);
    for (final item in _asList(response.data)) {
      final map = _asMap(item);
      if (_matchesRelation(map['cliente'], clienteId)) {
        return DireccionCliente.fromJson(map);
      }
    }
    return null;
  }

  Future<DireccionCliente> saveDireccion(DireccionCliente direccion) async {
    final response = direccion.id == 0
        ? await _dio.post(ApiEndpoints.direccionesCliente,
            data: direccion.toJson())
        : await _dio.put(
            '${ApiEndpoints.direccionesCliente}${direccion.id}/',
            data: direccion.toJson(),
          );

    final raw = response.data;
    if (raw is Map) {
      return DireccionCliente.fromJson(_asMap(raw));
    }
    return direccion;
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.cast<String, dynamic>();
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['results'] is List) {
      return raw['results'] as List;
    }
    return const [];
  }

  bool _matchesRelation(dynamic rawValue, int expectedId) {
    if (rawValue == null) return false;
    if (rawValue is int) return rawValue == expectedId;
    if (rawValue is String) return int.tryParse(rawValue) == expectedId;
    if (rawValue is Map) {
      final map = _asMap(rawValue);
      final nestedId = map['id'];
      if (nestedId is int) return nestedId == expectedId;
      if (nestedId is String) return int.tryParse(nestedId) == expectedId;
    }
    return false;
  }
}
