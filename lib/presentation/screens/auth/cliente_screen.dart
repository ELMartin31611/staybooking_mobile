import 'package:flutter/material.dart';

import '../../../domain/model/cliente.dart';

class ClienteScreen extends StatelessWidget {
  const ClienteScreen({super.key, required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos del cliente')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Item(label: 'Cédula', value: cliente.cedula),
          _Item(label: 'Nombres', value: cliente.nombres),
          _Item(label: 'Apellidos', value: cliente.apellidos),
          _Item(label: 'Género', value: cliente.genero),
          _Item(label: 'Nacionalidad', value: cliente.nacionalidad),
          _Item(label: 'Correo alternativo', value: cliente.correoAlternativo),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(value == null || value!.isEmpty ? '-' : value!),
          ),
        ],
      ),
    );
  }
}
