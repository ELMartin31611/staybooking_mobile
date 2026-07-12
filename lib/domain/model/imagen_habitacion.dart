class ImagenHabitacion {
  final int id;
  final int? habitacionId;
  final String imagenUrl;
  final String descripcion;
  final bool esPrincipal;
  final int orden;
  final Map<String, dynamic> raw;

  const ImagenHabitacion({
    required this.id,
    this.habitacionId,
    required this.imagenUrl,
    required this.descripcion,
    required this.esPrincipal,
    required this.orden,
    required this.raw,
  });

  factory ImagenHabitacion.fromJson(Map<String, dynamic> json) {
    return ImagenHabitacion(
      id: _toInt(json['id']) ?? 0,
      habitacionId: _readId(
        json['habitacion'] ?? json['habitacion_id'],
      ),
      imagenUrl: (json['imagen_url'] ??
              json['imagen'] ??
              json['url'] ??
              json['foto_url'] ??
              '')
          .toString(),
      descripcion:
          (json['descripcion'] ?? json['description'] ?? '').toString(),
      esPrincipal: _toBool(
        json['es_principal'] ??
            json['principal'] ??
            json['is_primary'] ??
            false,
      ),
      orden: _toInt(
            json['orden'] ?? json['posicion'],
          ) ??
          0,
      raw: Map<String, dynamic>.from(json),
    );
  }

  static int? _readId(dynamic value) {
    if (value is Map) {
      return _toInt(value['id']);
    }

    return _toInt(value);
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    final text = value.toString().toLowerCase();

    return text == 'true' || text == '1' || text == 'si' || text == 'sí';
  }
}

class PaginatedImagenesHabitacion {
  final int count;
  final String? next;
  final String? previous;
  final List<ImagenHabitacion> results;

  const PaginatedImagenesHabitacion({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PaginatedImagenesHabitacion.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['results'];

    final results = data is List
        ? data
            .whereType<Map>()
            .map(
              (item) => ImagenHabitacion.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <ImagenHabitacion>[];

    return PaginatedImagenesHabitacion(
      count: int.tryParse(
            json['count']?.toString() ?? '',
          ) ??
          results.length,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: results,
    );
  }
}
