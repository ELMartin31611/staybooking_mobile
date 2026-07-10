class DireccionCliente {
  final int id;
  final int cliente;
  final String provincia;
  final String ciudad;
  final String callePrincipal;
  final String? calleSecundaria;
  final String? referencia;
  final String? codigoPostal;
  final bool esPrincipal;

  DireccionCliente({
    required this.id,
    required this.cliente,
    required this.provincia,
    required this.ciudad,
    required this.callePrincipal,
    this.calleSecundaria,
    this.referencia,
    this.codigoPostal,
    required this.esPrincipal,
  });

  factory DireccionCliente.fromJson(Map<String, dynamic> json) {
    return DireccionCliente(
      id: json['id'],
      cliente: json['cliente'],
      provincia: json['provincia'],
      ciudad: json['ciudad'],
      callePrincipal: json['calle_principal'],
      calleSecundaria: json['calle_secundaria'],
      referencia: json['referencia'],
      codigoPostal: json['codigo_postal'],
      esPrincipal: json['es_principal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'provincia': provincia,
      'ciudad': ciudad,
      'calle_principal': callePrincipal,
      'calle_secundaria': calleSecundaria,
      'referencia': referencia,
      'codigo_postal': codigoPostal,
      'es_principal': esPrincipal,
    };
  }
}
