import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/cama_provider.dart';
import '../../providers/tipo_habitacion_cama_provider.dart';

class TipoHabitacionCamaScreen extends ConsumerWidget {
  final int tipoHabitacionId;

  const TipoHabitacionCamaScreen({
    super.key,
    required this.tipoHabitacionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relacionesAsync = ref.watch(
      camasPorTipoHabitacionProvider(tipoHabitacionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camas de la habitación'),
      ),
      body: relacionesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          onRetry: () {
            ref.invalidate(
              camasPorTipoHabitacionProvider(tipoHabitacionId),
            );
          },
        ),
        data: (page) {
          if (page.results.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                camasPorTipoHabitacionProvider(tipoHabitacionId),
              );

              await ref.read(
                camasPorTipoHabitacionProvider(
                  tipoHabitacionId,
                ).future,
              );
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: page.results.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final relacion = page.results[index];

                return _CamaRelacionCard(
                  camaId: relacion.camaId,
                  cantidad: relacion.cantidad,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CamaRelacionCard extends ConsumerWidget {
  final int? camaId;
  final int cantidad;

  const _CamaRelacionCard({
    required this.camaId,
    required this.cantidad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (camaId == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.bed_outlined),
          title: const Text('Tipo de cama no disponible'),
          subtitle: Text('Cantidad: $cantidad'),
        ),
      );
    }

    final camaAsync = ref.watch(
      camaDetalleProvider(camaId!),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: camaAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => ListTile(
          leading: const Icon(Icons.bed_outlined),
          title: Text('Cama #$camaId'),
          subtitle: Text('Cantidad: $cantidad'),
        ),
        data: (cama) {
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
                    Icons.bed,
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
                        cama.nombre,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (cama.descripcion.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(cama.descripcion),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(
                              Icons.bed_outlined,
                              size: 18,
                            ),
                            label: Text(
                              'Cantidad: $cantidad',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(
                              Icons.people,
                              size: 18,
                            ),
                            label: Text(
                              '${cama.capacidad} persona(s)',
                            ),
                          ),
                          Chip(
                            label: Text(cama.estado),
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
              'Este tipo de habitación todavía no tiene camas asociadas.',
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
              'No se pudieron cargar las camas asociadas.',
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
