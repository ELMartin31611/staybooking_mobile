import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/servicio.dart';
import '../../providers/servicio_provider.dart';

class ServicioCatalogScreen extends ConsumerStatefulWidget {
  const ServicioCatalogScreen({
    super.key,
  });

  @override
  ConsumerState<ServicioCatalogScreen> createState() =>
      _ServicioCatalogScreenState();
}

class _ServicioCatalogScreenState extends ConsumerState<ServicioCatalogScreen> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    final serviciosAsync = ref.watch(
      serviciosProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Servicios',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _busqueda = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar servicio',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: serviciosAsync.when(
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              error: (error, stackTrace) {
                return _ErrorView(
                  onRetry: () {
                    ref.invalidate(
                      serviciosProvider,
                    );
                  },
                );
              },
              data: (page) {
                final servicios = page.results.where((servicio) {
                  if (_busqueda.isEmpty) {
                    return true;
                  }

                  return servicio.nombre.toLowerCase().contains(_busqueda) ||
                      servicio.descripcion.toLowerCase().contains(_busqueda);
                }).toList();

                if (servicios.isEmpty) {
                  return const _EmptyView();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      serviciosProvider,
                    );

                    await ref.read(
                      serviciosProvider.future,
                    );
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: servicios.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: 12,
                      );
                    },
                    itemBuilder: (context, index) {
                      return _ServicioCard(
                        servicio: servicios[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicioCard extends StatelessWidget {
  final Servicio servicio;

  const _ServicioCard({
    required this.servicio,
  });

  @override
  Widget build(BuildContext context) {
    final precioTexto = servicio.precio <= 0
        ? 'Incluido'
        : '\$${servicio.precio.toStringAsFixed(2)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _iconoServicio(
                  servicio.nombre,
                ),
                size: 32,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servicio.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (servicio.descripcion.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      servicio.descripcion,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(
                          Icons.payments_outlined,
                          size: 18,
                        ),
                        label: Text(
                          precioTexto,
                        ),
                      ),
                      Chip(
                        avatar: Icon(
                          servicio.activo ? Icons.check_circle : Icons.cancel,
                          size: 18,
                        ),
                        label: Text(
                          servicio.estado,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconoServicio(
    String nombre,
  ) {
    final texto = nombre.toLowerCase();

    if (texto.contains('wifi') || texto.contains('internet')) {
      return Icons.wifi;
    }

    if (texto.contains('desayuno') ||
        texto.contains('comida') ||
        texto.contains('restaurante')) {
      return Icons.restaurant;
    }

    if (texto.contains('piscina')) {
      return Icons.pool;
    }

    if (texto.contains('parqueadero') || texto.contains('estacionamiento')) {
      return Icons.local_parking;
    }

    if (texto.contains('limpieza')) {
      return Icons.cleaning_services;
    }

    if (texto.contains('gimnasio')) {
      return Icons.fitness_center;
    }

    if (texto.contains('aire')) {
      return Icons.ac_unit;
    }

    return Icons.room_service;
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.room_service_outlined,
              size: 70,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron servicios.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron cargar los servicios.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
