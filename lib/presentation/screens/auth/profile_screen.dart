import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/cliente.dart';
import '../../../domain/model/direccion_cliente.dart';
import '../../providers/auth_provider.dart';
import 'cliente_screen.dart';
import 'direccion_cliente_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ClienteScreen(
                      cliente: Cliente(
                        id: 0,
                        perfil: perfil?.id ?? 0,
                        cedula: '',
                        nombres: '',
                        apellidos: '',
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Datos del cliente'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DireccionClienteScreen(
                      direccion: DireccionCliente(
                        id: 0,
                        cliente: 0,
                        provincia: '',
                        ciudad: '',
                        callePrincipal: '',
                        esPrincipal: true,
                      ),
                    ),
                  ),
                );
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
