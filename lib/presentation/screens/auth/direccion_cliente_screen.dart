import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/cliente.dart';
import '../../../domain/model/direccion_cliente.dart';
import '../../providers/auth_provider.dart';
import 'cliente_screen.dart';

class DireccionClienteScreen extends ConsumerStatefulWidget {
  const DireccionClienteScreen({super.key, required this.perfilId});

  final int perfilId;

  @override
  ConsumerState<DireccionClienteScreen> createState() =>
      _DireccionClienteScreenState();
}

class _DireccionClienteScreenState
    extends ConsumerState<DireccionClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _provinciaController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _callePrincipalController = TextEditingController();
  final _calleSecundariaController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _codigoPostalController = TextEditingController();

  Cliente? _cliente;
  DireccionCliente? _direccion;
  bool _esPrincipal = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDireccion();
  }

  @override
  void dispose() {
    _provinciaController.dispose();
    _ciudadController.dispose();
    _callePrincipalController.dispose();
    _calleSecundariaController.dispose();
    _referenciaController.dispose();
    _codigoPostalController.dispose();
    super.dispose();
  }

  Future<void> _loadDireccion() async {
    final repository = ref.read(authRepositoryProvider);
    final cliente = await repository.getClienteByPerfil(widget.perfilId);

    if (!mounted) return;

    _cliente = cliente;

    if (_cliente != null) {
      _direccion = await repository.getDireccionByCliente(_cliente!.id);
    }

    if (!mounted) return;

    if (_direccion != null) {
      _provinciaController.text = _direccion!.provincia;
      _ciudadController.text = _direccion!.ciudad;
      _callePrincipalController.text = _direccion!.callePrincipal;
      _calleSecundariaController.text = _direccion!.calleSecundaria ?? '';
      _referenciaController.text = _direccion!.referencia ?? '';
      _codigoPostalController.text = _direccion!.codigoPostal ?? '';
      _esPrincipal = _direccion!.esPrincipal;
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveDireccion() async {
    if (_cliente == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final saved = await repository.saveDireccion(
        DireccionCliente(
          id: _direccion?.id ?? 0,
          cliente: _cliente!.id,
          provincia: _provinciaController.text.trim(),
          ciudad: _ciudadController.text.trim(),
          callePrincipal: _callePrincipalController.text.trim(),
          calleSecundaria: _calleSecundariaController.text.trim().isEmpty
              ? null
              : _calleSecundariaController.text.trim(),
          referencia: _referenciaController.text.trim().isEmpty
              ? null
              : _referenciaController.text.trim(),
          codigoPostal: _codigoPostalController.text.trim().isEmpty
              ? null
              : _codigoPostalController.text.trim(),
          esPrincipal: _esPrincipal,
        ),
      );

      if (!mounted) return;

      setState(() {
        _direccion = saved;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dirección guardada')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la dirección: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dirección del cliente')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cliente == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Primero guarda los datos del cliente para poder añadir la dirección.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ClienteScreen(
                                  perfilId: widget.perfilId,
                                ),
                              ),
                            );
                          },
                          child: const Text('Ir a datos del cliente'),
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _Field(
                          controller: _provinciaController, label: 'Provincia'),
                      const SizedBox(height: 14),
                      _Field(controller: _ciudadController, label: 'Ciudad'),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _callePrincipalController,
                        label: 'Calle principal',
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _calleSecundariaController,
                        label: 'Calle secundaria',
                      ),
                      const SizedBox(height: 14),
                      _Field(
                          controller: _referenciaController,
                          label: 'Referencia'),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _codigoPostalController,
                        label: 'Código postal',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dirección principal'),
                        value: _esPrincipal,
                        onChanged: (value) {
                          setState(() {
                            _esPrincipal = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _saving ? null : _saveDireccion,
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar dirección'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa $label';
        }
        return null;
      },
    );
  }
}
