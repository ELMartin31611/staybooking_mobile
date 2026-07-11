class Hotel {
  final int id;
  final String nombre;
  final String ruc;
  final String telefono;
  final String email;
  final String descripcion;
  final int categoriaEstrellas;
  final String? sitioWeb;
  final String? logoUrl;
  final String estado;
  final String horaCheckIn;
  final String horaCheckOut;
  final bool permiteMascotas;
  final int edadMinimaReserva;
  final String politicaCancelacion;
  final String createdAt;
  final String updatedAt;

  const Hotel({
    required this.id,
    required this.nombre,
    required this.ruc,
    required this.telefono,
    required this.email,
    required this.descripcion,
    required this.categoriaEstrellas,
    this.sitioWeb,
    this.logoUrl,
    required this.estado,
    required this.horaCheckIn,
    required this.horaCheckOut,
    required this.permiteMascotas,
    required this.edadMinimaReserva,
    required this.politicaCancelacion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as int,
      nombre: json['nombre']?.toString() ?? '',
      ruc: json['ruc']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      categoriaEstrellas:
          int.tryParse(json['categoria_estrellas']?.toString() ?? '') ?? 0,
      sitioWeb: json['sitio_web']?.toString(),
      logoUrl: json['logo_url']?.toString(),
      estado: json['estado']?.toString() ?? '',
      horaCheckIn: json['hora_check_in']?.toString() ?? '',
      horaCheckOut: json['hora_check_out']?.toString() ?? '',
      permiteMascotas: json['permite_mascotas'] as bool? ?? false,
      edadMinimaReserva:
          int.tryParse(json['edad_minima_reserva']?.toString() ?? '') ?? 0,
      politicaCancelacion: json['politica_cancelacion']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'ruc': ruc,
      'telefono': telefono,
      'email': email,
      'descripcion': descripcion,
      'categoria_estrellas': categoriaEstrellas,
      'sitio_web': sitioWeb,
      'logo_url': logoUrl,
      'estado': estado,
      'hora_check_in': horaCheckIn,
      'hora_check_out': horaCheckOut,
      'permite_mascotas': permiteMascotas,
      'edad_minima_reserva': edadMinimaReserva,
      'politica_cancelacion': politicaCancelacion,
    };
  }

  Hotel copyWith({
    String? nombre,
    String? telefono,
    String? email,
    String? descripcion,
    int? categoriaEstrellas,
    String? sitioWeb,
    String? logoUrl,
    String? estado,
    String? horaCheckIn,
    String? horaCheckOut,
    bool? permiteMascotas,
    int? edadMinimaReserva,
    String? politicaCancelacion,
  }) {
    return Hotel(
      id: id,
      nombre: nombre ?? this.nombre,
      ruc: ruc,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      descripcion: descripcion ?? this.descripcion,
      categoriaEstrellas: categoriaEstrellas ?? this.categoriaEstrellas,
      sitioWeb: sitioWeb ?? this.sitioWeb,
      logoUrl: logoUrl ?? this.logoUrl,
      estado: estado ?? this.estado,
      horaCheckIn: horaCheckIn ?? this.horaCheckIn,
      horaCheckOut: horaCheckOut ?? this.horaCheckOut,
      permiteMascotas: permiteMascotas ?? this.permiteMascotas,
      edadMinimaReserva: edadMinimaReserva ?? this.edadMinimaReserva,
      politicaCancelacion: politicaCancelacion ?? this.politicaCancelacion,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PaginatedHotels {
  final int count;
  final String? next;
  final String? previous;
  final List<Hotel> results;

  const PaginatedHotels({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PaginatedHotels.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'];

    return PaginatedHotels(
      count: json['count'] as int? ?? 0,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
      results: rawResults is List
          ? rawResults
              .map(
                (item) => Hotel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList()
          : <Hotel>[],
    );
  }
}
