import 'package:dio/dio.dart';

import '../../../../core/config/api_endpoints.dart';
import '../../../../core/config/app_config.dart';
import '../../local/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SecureStorage secureStorage})
      : _secureStorage = secureStorage,
        _refreshDio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  final SecureStorage _secureStorage;
  final Dio _refreshDio;

  Future<String?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers['Authorization'] == null) {
      final access = await _secureStorage.getAccessToken();
      if (access != null && access.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $access';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final request = err.requestOptions;
    final isRefreshCall = request.path.contains(ApiEndpoints.refresh);
    final alreadyRetried = request.extra['auth_retry'] == true;

    if (status != 401 || isRefreshCall || alreadyRetried) {
      handler.next(err);
      return;
    }

    final newAccess = await _refreshAccessToken();
    if (newAccess == null || newAccess.isEmpty) {
      await _secureStorage.clearTokens();
      handler.next(err);
      return;
    }

    request.headers['Authorization'] = 'Bearer $newAccess';
    request.extra['auth_retry'] = true;

    try {
      final retryResponse = await _refreshDio.fetch(request);
      handler.resolve(retryResponse);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture;
    }

    _refreshFuture = _doRefresh();
    final access = await _refreshFuture;
    _refreshFuture = null;
    return access;
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refresh': refreshToken},
      );

      final data = response.data;
      if (data is! Map) return null;

      final map = data.cast<String, dynamic>();
      final access = (map['access'] ?? '').toString();
      final refresh = (map['refresh'] ?? refreshToken).toString();

      if (access.isEmpty) return null;

      await _secureStorage.saveTokens(
        accessToken: access,
        refreshToken: refresh,
      );
      return access;
    } on DioException {
      return null;
    }
  }
}
