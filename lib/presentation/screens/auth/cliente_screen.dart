import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/cliente.dart';
import '../../providers/auth_provider.dart';

class ClienteScreen extends ConsumerStatefulWidget {
  const ClienteScreen({super.key, required this.perfilId});

  final int perfilId;

  @override
  ConsumerState<ClienteScreen> createState() => _ClienteScreenState();
}

class _ClienteScreenState extends ConsumerState<ClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _generoController = TextEditingController();
  final _nacionalidadController = TextEditingController();
  final _correoAlternativoController = TextEditingController();

  Cliente? _cliente;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCliente();
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _generoController.dispose();
    _nacionalidadController.dispose();
    _correoAlternativoController.dispose();
    super.dispose();
  }

  Future<void> _loadCliente() async {
    final repository = ref.read(authRepositoryProvider);
    final cliente = await repository.getClienteByPerfil(widget.perfilId);

    if (!mounted) return;

    _cliente = cliente ?? Cliente(
      id: 0,
      perfil: widget.perfilId,
      cedula: '',
      nombres: '',
      apellidos: '',
    );

    _cedulaController.text = _cliente!.cedula;
    _nombresController.text = _cliente!.nombres;
    _apellidosController.text = _cliente!.apellidos;
    _generoController.text = _cliente!.genero ?? '';
    _nacionalidadController.text = _cliente!.nacionalidad ?? '';
    _correoAlternativoController.text = _cliente!.correoAlternativo ?? '';

    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveCliente() async {
    if (!_formKey.currentState!.validate() || _cliente == null) return;

    setState(() {
      _saving = true;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final saved = await repository.saveCliente(
        Cliente(
          id: _cliente!.id,
          perfil: widget.perfilId,
          cedula: _cedulaController.text.trim(),
          nombres: _nombresController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          genero: _generoController.text.trim().isEmpty
              ? null
              : _generoController.text.trim(),
          nacionalidad: _nacionalidadController.text.trim().isEmpty
              ? null
              : _nacionalidadController.text.trim(),
          correoAlternativo: _correoAlternativoController.text.trim().isEmpty
              ? null
              : _correoAlternativoController.text.trim(),
        ),
      );

      if (!mounted) return;

      setState(() {
        _cliente = saved;
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos del cliente guardados')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el cliente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos del cliente')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _Field(controller: _cedulaController, label: 'Cédula'),
                  const SizedBox(height: 14),
                  _Field(controller: _nombresController, label: 'Nombres'),
                  const SizedBox(height: 14),
                  _Field(controller: _apellidosController, label: 'Apellidos'),
                  const SizedBox(height: 14),
                  _Field(controller: _generoController, label: 'Género'),
                  const SizedBox(height: 14),
                  _Field(
                    controller: _nacionalidadController,
                    label: 'Nacionalidad',
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    controller: _correoAlternativoController,
                    label: 'Correo alternativo',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveCliente,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar cliente'),
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
