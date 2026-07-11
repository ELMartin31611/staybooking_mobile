class PerfilUsuario {
  final int id;
  final int user;
  final String username;
  final String email;
  final String rol;
  final String? telefono;
  final String? fotoUrl;
  final String estado;

  PerfilUsuario({
    required this.id,
    required this.user,
    required this.username,
    required this.email,
    required this.rol,
    this.telefono,
    this.fotoUrl,
    required this.estado,
  });

  factory PerfilUsuario.fromJson(Map<String, dynamic> json) {
    return PerfilUsuario(
      id: json['id'],
      user: json['user'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'],
      telefono: json['telefono'],
      fotoUrl: json['foto_url'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'username': username,
      'email': email,
      'rol': rol,
      'telefono': telefono,
      'foto_url': fotoUrl,
      'estado': estado,
    };
  }
}
