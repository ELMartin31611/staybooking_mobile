import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/servicio_provider.dart';
import '../../providers/tipo_habitacion_servicio_provider.dart';

class TipoHabitacionServicioScreen extends ConsumerWidget {
  final int tipoHabitacionId;

  const TipoHabitacionServicioScreen({
    super.key,
    required this.tipoHabitacionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relacionesAsync = ref.watch(
      serviciosPorTipoHabitacionProvider(
        tipoHabitacionId,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Servicios de la habitación',
        ),
      ),
      body: relacionesAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _ErrorView(
            onRetry: () {
              ref.invalidate(
                serviciosPorTipoHabitacionProvider(
                  tipoHabitacionId,
                ),
              );
            },
          );
        },
        data: (page) {
          final relaciones = page.results
              .where(
                (relacion) => relacion.activo,
              )
              .toList();

          if (relaciones.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                serviciosPorTipoHabitacionProvider(
                  tipoHabitacionId,
                ),
              );

              await ref.read(
                serviciosPorTipoHabitacionProvider(
                  tipoHabitacionId,
                ).future,
              );
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: relaciones.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final relacion = relaciones[index];

                return _ServicioRelacionCard(
                  servicioId: relacion.servicioId,
                  incluido: relacion.incluido,
                  precioAdicional: relacion.precioAdicional,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ServicioRelacionCard extends ConsumerWidget {
  final int? servicioId;
  final bool incluido;
  final double precioAdicional;

  const _ServicioRelacionCard({
    required this.servicioId,
    required this.incluido,
    required this.precioAdicional,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (servicioId == null) {
      return Card(
        child: ListTile(
          leading: const Icon(
            Icons.room_service_outlined,
          ),
          title: const Text(
            'Servicio no disponible',
          ),
          subtitle: Text(
            _precioTexto(),
          ),
        ),
      );
    }

    final servicioAsync = ref.watch(
      servicioDetalleProvider(servicioId!),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: servicioAsync.when(
        loading: () {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        error: (error, stackTrace) {
          return ListTile(
            leading: const Icon(
              Icons.room_service_outlined,
            ),
            title: Text(
              'Servicio #$servicioId',
            ),
            subtitle: Text(
              _precioTexto(),
            ),
          );
        },
        data: (servicio) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _iconoServicio(servicio.nombre),
                    size: 34,
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            avatar: Icon(
                              incluido
                                  ? Icons.check_circle
                                  : Icons.payments_outlined,
                              size: 18,
                            ),
                            label: Text(
                              _precioTexto(),
                            ),
                          ),
                          Chip(
                            avatar: Icon(
                              servicio.activo
                                  ? Icons.verified_outlined
                                  : Icons.cancel_outlined,
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
          );
        },
      ),
    );
  }

  String _precioTexto() {
    if (incluido || precioAdicional <= 0) {
      return 'Incluido';
    }

    return 'Adicional: \$${precioAdicional.toStringAsFixed(2)}';
  }

  IconData _iconoServicio(String nombre) {
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
              'Este tipo de habitación todavía no tiene servicios asociados.',
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
              'No se pudieron cargar los servicios asociados.',
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
