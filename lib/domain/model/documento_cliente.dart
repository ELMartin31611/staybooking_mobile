class DocumentoCliente {
  final int id;
  final int cliente;
  final String tipoDocumento;
  final String numeroDocumento;
  final String? archivoUrl;
  final bool verificado;

  DocumentoCliente({
    required this.id,
    required this.cliente,
    required this.tipoDocumento,
    required this.numeroDocumento,
    this.archivoUrl,
    required this.verificado,
  });

  factory DocumentoCliente.fromJson(Map<String, dynamic> json) {
    return DocumentoCliente(
      id: json['id'],
      cliente: json['cliente'],
      tipoDocumento: json['tipo_documento'],
      numeroDocumento: json['numero_documento'],
      archivoUrl: json['archivo_url'],
      verificado: json['verificado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': cliente,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
      'archivo_url': archivoUrl,
      'verificado': verificado,
    };
  }
}
