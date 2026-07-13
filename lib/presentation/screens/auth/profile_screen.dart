import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/cliente.dart';
import '../../../domain/model/direccion_cliente.dart';
import '../../providers/auth_provider.dart';
import 'cliente_screen.dart';
import 'direccion_cliente_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Cliente? _cliente;
  DireccionCliente? _direccion;
  bool _loadingExtra = true;

  @override
  void initState() {
    super.initState();
    _loadExtraData();
  }

  Future<void> _loadExtraData() async {
    final authState = ref.read(authControllerProvider);
    final perfil = authState.profile;

    if (perfil == null) {
      if (!mounted) return;
      setState(() {
        _loadingExtra = false;
      });
      return;
    }

    final repository = ref.read(authRepositoryProvider);
    final cliente = await repository.getClienteByPerfil(perfil.id);
    DireccionCliente? direccion;
    if (cliente != null) {
      direccion = await repository.getDireccionByCliente(cliente.id);
    }

    if (!mounted) return;
    setState(() {
      _cliente = cliente;
      _direccion = direccion;
      _loadingExtra = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final perfil = authState.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ProfileRow(label: 'Username', value: perfil?.username),
            _ProfileRow(label: 'Email', value: perfil?.email),
            _ProfileRow(label: 'Rol', value: perfil?.rol),
            _ProfileRow(label: 'Teléfono', value: perfil?.telefono),
            _ProfileRow(label: 'Estado', value: perfil?.estado),
            const SizedBox(height: 24),
            if (_loadingExtra)
              const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ))
            else ...[
              const _SectionTitle(title: 'Cliente'),
              _ProfileRow(label: 'Cédula', value: _cliente?.cedula),
              _ProfileRow(label: 'Nombres', value: _cliente?.nombres),
              _ProfileRow(label: 'Apellidos', value: _cliente?.apellidos),
              _ProfileRow(label: 'Género', value: _cliente?.genero),
              _ProfileRow(label: 'Nacionalidad', value: _cliente?.nacionalidad),
              _ProfileRow(
                label: 'Correo alternativo',
                value: _cliente?.correoAlternativo,
              ),
              const SizedBox(height: 20),
              const _SectionTitle(title: 'Dirección'),
              _ProfileRow(label: 'Provincia', value: _direccion?.provincia),
              _ProfileRow(label: 'Ciudad', value: _direccion?.ciudad),
              _ProfileRow(
                label: 'Calle principal',
                value: _direccion?.callePrincipal,
              ),
              _ProfileRow(
                label: 'Calle secundaria',
                value: _direccion?.calleSecundaria,
              ),
              _ProfileRow(label: 'Referencia', value: _direccion?.referencia),
              _ProfileRow(
                  label: 'Código postal', value: _direccion?.codigoPostal),
              const SizedBox(height: 24),
            ],
            OutlinedButton(
              onPressed: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => ClienteScreen(
                      perfilId: perfil?.id ?? 0,
                    ),
                  ),
                );
                if (changed == true && mounted) {
                  setState(() {
                    _loadingExtra = true;
                  });
                  await _loadExtraData();
                }
              },
              child: const Text('Datos del cliente'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final changed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => DireccionClienteScreen(
                      perfilId: perfil?.id ?? 0,
                    ),
                  ),
                );
                if (changed == true && mounted) {
                  setState(() {
                    _loadingExtra = true;
                  });
                  await _loadExtraData();
                }
              },
              child: const Text('Dirección del cliente'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, this.value});

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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
