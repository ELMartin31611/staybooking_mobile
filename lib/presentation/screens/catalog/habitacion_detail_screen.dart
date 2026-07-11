import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/habitacion_provider.dart';

class HabitacionDetailScreen extends ConsumerWidget {
  final int habitacionId;

  const HabitacionDetailScreen({
    super.key,
    required this.habitacionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitacionAsync = ref.watch(
      habitacionDetalleProvider(habitacionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de habitación'),
      ),
      body: habitacionAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo cargar la habitación.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(
                        habitacionDetalleProvider(
                          habitacionId,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (habitacion) {
          final nombreHabitacion = habitacion.numero.trim().isEmpty
              ? 'Habitación ${habitacion.id}'
              : 'Habitación ${habitacion.numero}';

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                habitacionDetalleProvider(habitacionId),
              );

              await ref.read(
                habitacionDetalleProvider(
                  habitacionId,
                ).future,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  height: 210,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    Icons.bed,
                    size: 100,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  nombreHabitacion,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Chip(
                      avatar: const Icon(
                        Icons.layers,
                        size: 18,
                      ),
                      label: Text(
                        'Piso ${habitacion.piso}',
                      ),
                    ),
                    Chip(
                      avatar: Icon(
                        habitacion.disponible
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 18,
                      ),
                      label: Text(
                        habitacion.disponible ? 'Disponible' : 'No disponible',
                      ),
                    ),
                    Chip(
                      avatar: const Icon(
                        Icons.info_outline,
                        size: 18,
                      ),
                      label: Text(
                        habitacion.estado,
                      ),
                    ),
                  ],
                ),
                if (habitacion.descripcion.trim().isNotEmpty) ...[
                  const SizedBox(height: 26),
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    habitacion.descripcion,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: habitacion.disponible
                        ? () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$nombreHabitacion seleccionada para la reserva',
                                  ),
                                ),
                              );
                          }
                        : null,
                    icon: const Icon(
                      Icons.add_shopping_cart,
                    ),
                    label: Text(
                      habitacion.disponible
                          ? 'Seleccionar habitación'
                          : 'Habitación no disponible',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
