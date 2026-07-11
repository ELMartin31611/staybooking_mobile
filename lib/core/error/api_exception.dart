import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors,
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? fieldErrors;

  factory ApiException.fromDioError(
    DioException error,
  ) {
    final response = error.response;
    final statusCode = response?.statusCode;

    if (response?.data == null) {
      return ApiException(
        error.message ?? 'Error de conexión',
        statusCode: statusCode,
      );
    }

    final data = response!.data;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        return ApiException(
          data['detail'].toString(),
          statusCode: statusCode,
        );
      }

      if (data.containsKey('error')) {
        return ApiException(
          data['error'].toString(),
          statusCode: statusCode,
        );
      }

      if (data.containsKey('non_field_errors')) {
        final errors = data['non_field_errors'];

        final message = errors is List && errors.isNotEmpty
            ? errors.first.toString()
            : errors.toString();

        return ApiException(
          message,
          statusCode: statusCode,
        );
      }

      final fieldErrors = <String, dynamic>{};
      String? firstMessage;

      data.forEach((key, value) {
        final message = value is List && value.isNotEmpty
            ? value.first.toString()
            : value.toString();

        fieldErrors[key] = message;
        firstMessage ??= '$key: $message';
      });

      return ApiException(
        firstMessage ?? 'Error de validación',
        statusCode: statusCode,
        fieldErrors: fieldErrors,
      );
    }

    return ApiException(
      data.toString(),
      statusCode: statusCode,
    );
  }

  String? fieldError(String field) {
    return fieldErrors?[field]?.toString();
  }

  @override
  String toString() {
    return message;
  }
}
