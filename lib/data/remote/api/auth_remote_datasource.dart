import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../domain/model/auth_response.dart';
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

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.cast<String, dynamic>();
    return <String, dynamic>{};
  }
}
