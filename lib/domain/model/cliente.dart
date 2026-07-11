class Cliente {
  final int id;
  final int perfil;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String? genero;
  final String? nacionalidad;
  final String? correoAlternativo;

  Cliente({
    required this.id,
    required this.perfil,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    this.genero,
    this.nacionalidad,
    this.correoAlternativo,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      perfil: json['perfil'],
      cedula: json['cedula'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      genero: json['genero'],
      nacionalidad: json['nacionalidad'],
      correoAlternativo: json['correo_alternativo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'perfil': perfil,
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'genero': genero,
      'nacionalidad': nacionalidad,
      'correo_alternativo': correoAlternativo,
    };
  }
}
