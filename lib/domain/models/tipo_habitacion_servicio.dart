class TipoHabitacionServicio {
  final int id;
  final int? tipoHabitacionId;
  final int? servicioId;
  final bool incluido;
  final double precioAdicional;
  final bool activo;
  final Map<String, dynamic> raw;

  const TipoHabitacionServicio({
    required this.id,
    required this.tipoHabitacionId,
    required this.servicioId,
    required this.incluido,
    required this.precioAdicional,
    required this.activo,
    required this.raw,
  });

  factory TipoHabitacionServicio.fromJson(
    Map<String, dynamic> json,
  ) {
    final precioAdicional = _toDouble(
      json['precio_adicional'] ??
          json['precioAdicional'] ??
          json['precio'] ??
          json['costo_adicional'] ??
          0,
    );

    return TipoHabitacionServicio(
      id: _toInt(json['id']),
      tipoHabitacionId: _relationId(
        json['tipo_habitacion'] ??
            json['tipo_habitacion_id'] ??
            json['tipoHabitacion'] ??
            json['tipoHabitacionId'],
      ),
      servicioId: _relationId(
        json['servicio'] ??
            json['servicio_id'] ??
            json['servicioId'],
      ),
      incluido: _toBool(
        json['incluido'] ??
            json['es_incluido'] ??
            json['included'] ??
            precioAdicional <= 0,
      ),
      precioAdicional: precioAdicional,
      activo: _toBool(
        json['activo'] ??
            json['is_active'] ??
            json['disponible'] ??
            true,
      ),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _relationId(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map) {
      return _nullableInt(
        value['id'] ??
            value['pk'],
      );
    }

    return _nullableInt(value);
  }

  static int? _nullableInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final text =
        value?.toString().trim().toLowerCase() ?? '';

    return text == 'true' ||
        text == '1' ||
        text == 'si' ||
        text == 'sí' ||
        text == 'activo' ||
        text == 'incluido' ||
        text == 'disponible';
  }
}

class TipoHabitacionServicioPage {
  final int count;
  final String? next;
  final String? previous;
  final List<TipoHabitacionServicio> results;

  const TipoHabitacionServicioPage({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory TipoHabitacionServicioPage.fromJson(
    dynamic data,
  ) {
    if (data is List) {
      final results = data
          .whereType<Map>()
          .map(
            (item) =>
                TipoHabitacionServicio.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      return TipoHabitacionServicioPage(
        count: results.length,
        next: null,
        previous: null,
        results: results,
      );
    }

    if (data is Map) {
      final json = Map<String, dynamic>.from(data);

      final dynamic rawResults =
          json['results'] ??
          json['data'] ??
          json['tipos_habitacion_servicios'] ??
          json['servicios'] ??
          [];

      final results = rawResults is List
          ? rawResults
              .whereType<Map>()
              .map(
                (item) =>
                    TipoHabitacionServicio.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <TipoHabitacionServicio>[];

      final count = _toInt(json['count']);

      return TipoHabitacionServicioPage(
        count: count == 0 ? results.length : count,
        next: json['next']?.toString(),
        previous: json['previous']?.toString(),
        results: results,
      );
    }

    return const TipoHabitacionServicioPage(
      count: 0,
      next: null,
      previous: null,
      results: [],
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}