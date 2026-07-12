class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String estado;
  final bool activo;
  final Map<String, dynamic> raw;

  const Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.estado,
    required this.activo,
    required this.raw,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    final activo = _toBool(
      json['activo'] ?? json['is_active'] ?? json['disponible'] ?? true,
    );

    return Servicio(
      id: _toInt(json['id']),
      nombre: _toText(
        json['nombre'] ?? json['name'] ?? json['titulo'],
        'Servicio',
      ),
      descripcion: _toText(
        json['descripcion'] ?? json['description'] ?? json['detalle'],
        '',
      ),
      precio: _toDouble(
        json['precio'] ?? json['price'] ?? json['costo'] ?? 0,
      ),
      estado: _toText(
        json['estado'] ?? json['status'],
        activo ? 'activo' : 'inactivo',
      ),
      activo: activo,
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

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final text = value?.toString().trim().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'si' ||
        text == 'sí' ||
        text == 'activo' ||
        text == 'disponible';
  }

  static String _toText(
    dynamic value,
    String fallback,
  ) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
  }
}

class ServicioPage {
  final int count;
  final String? next;
  final String? previous;
  final List<Servicio> results;

  const ServicioPage({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory ServicioPage.fromJson(dynamic data) {
    if (data is List) {
      final results = data
          .whereType<Map>()
          .map(
            (item) => Servicio.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      return ServicioPage(
        count: results.length,
        next: null,
        previous: null,
        results: results,
      );
    }

    if (data is Map) {
      final json = Map<String, dynamic>.from(data);

      final dynamic rawResults =
          json['results'] ?? json['data'] ?? json['servicios'] ?? [];

      final results = rawResults is List
          ? rawResults
              .whereType<Map>()
              .map(
                (item) => Servicio.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <Servicio>[];

      return ServicioPage(
        count:
            _toInt(json['count']) == 0 ? results.length : _toInt(json['count']),
        next: json['next']?.toString(),
        previous: json['previous']?.toString(),
        results: results,
      );
    }

    return const ServicioPage(
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

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
