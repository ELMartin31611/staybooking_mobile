import 'package:dio/dio.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../core/error/api_exception.dart';
import '../../../domain/model/factura.dart';
import '../../../domain/model/pago.dart';

class BillingRemoteDataSource {
  BillingRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Pago>> getPagos({
    int? reservaId,
    MetodoPago? metodoPago,
    PagoEstado? estado,
    String? search,
  }) {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.pagos,
        queryParameters: _cleanQueryParameters({
          'reserva': reservaId,
          'metodo_pago': metodoPago?.apiValue,
          'estado': estado?.apiValue,
          'search': search,
          'page_size': 100,
        }),
      );

      return _extractResults(response.data)
          .map(Pago.fromJson)
          .toList(growable: false);
    });
  }

  Future<Pago> getPagoById(int id) {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '${ApiEndpoints.pagos}$id/',
      );

      return Pago.fromJson(
        _extractObject(response.data),
      );
    });
  }

  Future<Pago> createPago(PagoRequest request) {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        ApiEndpoints.pagos,
        data: request.toJson(),
      );

      return Pago.fromJson(
        _extractObject(response.data),
      );
    });
  }

  Future<Pago> updatePagoEstado(
    int id,
    PagoEstado estado,
  ) {
    return _guard(() async {
      final response = await _dio.patch<dynamic>(
        '${ApiEndpoints.pagos}$id/',
        data: {
          'estado': estado.apiValue,
        },
      );

      return Pago.fromJson(
        _extractObject(response.data),
      );
    });
  }

  Future<List<Factura>> getFacturas({
    int? reservaId,
    int? clienteId,
    FacturaEstado? estado,
    String? search,
  }) {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.facturas,
        queryParameters: _cleanQueryParameters({
          'reserva': reservaId,
          'cliente': clienteId,
          'estado': estado?.apiValue,
          'search': search,
          'page_size': 100,
        }),
      );

      return _extractResults(response.data)
          .map(Factura.fromJson)
          .toList(growable: false);
    });
  }

  Future<Factura> getFacturaById(int id) {
    return _guard(() async {
      final response = await _dio.get<dynamic>(
        '${ApiEndpoints.facturas}$id/',
      );

      return Factura.fromJson(
        _extractObject(response.data),
      );
    });
  }

  Future<T> _guard<T>(
    Future<T> Function() action,
  ) async {
    try {
      return await action();
    } on DioException catch (error) {
      throw ApiException.fromDioError(error);
    } on FormatException {
      throw const ApiException(
        'La respuesta del servidor tiene un formato inválido.',
      );
    }
  }

  Map<String, dynamic> _cleanQueryParameters(
    Map<String, dynamic> parameters,
  ) {
    final cleaned = Map<String, dynamic>.from(parameters);

    cleaned.removeWhere((key, value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;

      return false;
    });

    return cleaned;
  }

  List<Map<String, dynamic>> _extractResults(dynamic data) {
    final dynamic results;

    if (data is Map<String, dynamic>) {
      results = data['results'];
    } else {
      results = data;
    }

    if (results is! List) {
      throw const FormatException();
    }

    return results.map<Map<String, dynamic>>((item) {
      if (item is! Map) {
        throw const FormatException();
      }

      return Map<String, dynamic>.from(item);
    }).toList(growable: false);
  }

  Map<String, dynamic> _extractObject(dynamic data) {
    if (data is! Map) {
      throw const FormatException();
    }

    return Map<String, dynamic>.from(data);
  }
}
