class DireccionHotel {
  final int id;
  final int hotel;
  final String provincia;
  final String ciudad;
  final String direccion;
  final String referencia;
  final double? latitud;
  final double? longitud;
  final String createdAt;
  final String updatedAt;

  const DireccionHotel({
    required this.id,
    required this.hotel,
    required this.provincia,
    required this.ciudad,
    required this.direccion,
    required this.referencia,
    this.latitud,
    this.longitud,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DireccionHotel.fromJson(Map<String, dynamic> json) {
    return DireccionHotel(
      id: json['id'] as int,
      hotel: json['hotel'] is Map<String, dynamic>
          ? (json['hotel']['id'] as int)
          : int.tryParse(json['hotel']?.toString() ?? '') ?? 0,
      provincia: json['provincia']?.toString() ?? '',
      ciudad: json['ciudad']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      referencia: json['referencia']?.toString() ?? '',
      latitud: double.tryParse(json['latitud']?.toString() ?? ''),
      longitud: double.tryParse(json['longitud']?.toString() ?? ''),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hotel': hotel,
      'provincia': provincia,
      'ciudad': ciudad,
      'direccion': direccion,
      'referencia': referencia,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}

class PaginatedDireccionesHotel {
  final int count;
  final String? next;
  final String? previous;
  final List<DireccionHotel> results;

  const PaginatedDireccionesHotel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PaginatedDireccionesHotel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawResults = json['results'];

    return PaginatedDireccionesHotel(
      count: json['count'] as int? ?? 0,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: rawResults is List
          ? rawResults
              .map(
                (item) => DireccionHotel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList()
          : <DireccionHotel>[],
    );
  }
}
