import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/imagen_habitacion_provider.dart';

class ImagenHabitacionScreen extends ConsumerWidget {
  final int habitacionId;

  const ImagenHabitacionScreen({
    super.key,
    required this.habitacionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagenesAsync = ref.watch(
      imagenesPorHabitacionProvider(habitacionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Imágenes de la habitación'),
      ),
      body: imagenesAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _ErrorView(
            onRetry: () {
              ref.invalidate(
                imagenesPorHabitacionProvider(habitacionId),
              );
            },
          );
        },
        data: (page) {
          final imagenes = [...page.results]..sort(
              (a, b) => a.orden.compareTo(b.orden),
            );

          if (imagenes.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                imagenesPorHabitacionProvider(habitacionId),
              );

              await ref.read(
                imagenesPorHabitacionProvider(
                  habitacionId,
                ).future,
              );
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: imagenes.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                final imagen = imagenes[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imagen.imagenUrl.trim().isEmpty
                            ? const _ImagePlaceholder()
                            : Image.network(
                                imagen.imagenUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return const _ImagePlaceholder();
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    imagen.descripcion.trim().isEmpty
                                        ? 'Imagen de la habitación'
                                        : imagen.descripcion,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Posición: ${imagen.orden}',
                                  ),
                                ],
                              ),
                            ),
                            if (imagen.esPrincipal)
                              const Chip(
                                avatar: Icon(
                                  Icons.star,
                                  size: 18,
                                ),
                                label: Text('Principal'),
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
        },
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
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
              Icons.photo_library_outlined,
              size: 70,
            ),
            SizedBox(height: 16),
            Text(
              'Esta habitación todavía no tiene imágenes registradas.',
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
              'No se pudieron cargar las imágenes.',
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
