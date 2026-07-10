import 'package:flutter/material.dart';

import '../../../domain/model/direccion_cliente.dart';

class DireccionClienteScreen extends StatelessWidget {
  const DireccionClienteScreen({super.key, required this.direccion});

  final DireccionCliente direccion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dirección del cliente')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Item(label: 'Provincia', value: direccion.provincia),
          _Item(label: 'Ciudad', value: direccion.ciudad),
          _Item(label: 'Calle principal', value: direccion.callePrincipal),
          _Item(label: 'Calle secundaria', value: direccion.calleSecundaria),
          _Item(label: 'Referencia', value: direccion.referencia),
          _Item(label: 'Código postal', value: direccion.codigoPostal),
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
