class TipoHabitacionCama {
  final int id;
  final int? tipoHabitacionId;
  final int? camaId;
  final int cantidad;
  final Map<String, dynamic> raw;

  const TipoHabitacionCama({
    required this.id,
    this.tipoHabitacionId,
    this.camaId,
    required this.cantidad,
    required this.raw,
  });

  factory TipoHabitacionCama.fromJson(
    Map<String, dynamic> json,
  ) {
    return TipoHabitacionCama(
      id: _toInt(json['id']) ?? 0,
      tipoHabitacionId: _readId(
        json['tipo_habitacion'] ??
            json['tipo_habitacion_id'] ??
            json['tipoHabitacion'],
      ),
      camaId: _readId(
        json['cama'] ?? json['cama_id'],
      ),
      cantidad: _toInt(
            json['cantidad'] ?? json['numero_camas'] ?? json['total'],
          ) ??
          1,
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
}

class PaginatedTiposHabitacionCama {
  final int count;
  final String? next;
  final String? previous;
  final List<TipoHabitacionCama> results;

  const PaginatedTiposHabitacionCama({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PaginatedTiposHabitacionCama.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['results'];

    final results = data is List
        ? data
            .whereType<Map>()
            .map(
              (item) => TipoHabitacionCama.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <TipoHabitacionCama>[];

    return PaginatedTiposHabitacionCama(
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
