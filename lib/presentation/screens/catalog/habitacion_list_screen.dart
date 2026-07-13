import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/habitacion_provider.dart';

class HabitacionListScreen extends ConsumerWidget {
  final int hotelId;
  final int tipoHabitacionId;
  final String tipoNombre;

  const HabitacionListScreen({
    super.key,
    required this.hotelId,
    required this.tipoHabitacionId,
    required this.tipoNombre,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitacionesAsync = ref.watch(
      habitacionesPorTipoProvider(tipoHabitacionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tipoNombre),
      ),
      body: habitacionesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          return _ErrorView(
            onRetry: () {
              ref.invalidate(
                habitacionesPorTipoProvider(tipoHabitacionId),
              );
            },
          );
        },
        data: (page) {
          final habitaciones = page.results
              .where(
                (habitacion) =>
                    habitacion.hotelId == null || habitacion.hotelId == hotelId,
              )
              .toList();

          if (habitaciones.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                habitacionesPorTipoProvider(tipoHabitacionId),
              );

              await ref.read(
                habitacionesPorTipoProvider(
                  tipoHabitacionId,
                ).future,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: habitaciones.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final habitacion = habitaciones[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      context.push(
                        '/habitaciones/${habitacion.id}',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.bed,
                              size: 34,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habitacion.numero.isEmpty
                                      ? 'Habitación ${habitacion.id}'
                                      : 'Habitación ${habitacion.numero}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Piso ${habitacion.piso}',
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Chip(
                                      avatar: Icon(
                                        habitacion.disponible
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 18,
                                      ),
                                      label: Text(
                                        habitacion.disponible
                                            ? 'Disponible'
                                            : 'No disponible',
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        habitacion.estado,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
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
              Icons.bed_outlined,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No existen habitaciones registradas para este tipo.',
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
              'No se pudieron cargar las habitaciones.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
