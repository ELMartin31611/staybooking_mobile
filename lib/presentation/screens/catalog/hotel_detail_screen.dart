import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/hotel_provider.dart';
import '../../providers/tipo_habitacion_provider.dart';

class HotelDetailScreen extends ConsumerWidget {
  final int hotelId;

  const HotelDetailScreen({
    super.key,
    required this.hotelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelAsync = ref.watch(hotelDetalleProvider(hotelId));
    final tiposAsync = ref.watch(
      tiposHabitacionPorHotelProvider(hotelId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del hotel'),
      ),
      body: hotelAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorView(
          message: 'No se pudo cargar el hotel',
          onRetry: () {
            ref.invalidate(hotelDetalleProvider(hotelId));
            ref.invalidate(
              tiposHabitacionPorHotelProvider(hotelId),
            );
          },
        ),
        data: (hotel) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(hotelDetalleProvider(hotelId));
              ref.invalidate(
                tiposHabitacionPorHotelProvider(hotelId),
              );

              await ref.read(
                hotelDetalleProvider(hotelId).future,
              );
            },
            child: ListView(
              padding: const EdgeInsets.only(
                bottom: 32,
              ),
              children: [
                SizedBox(
                  height: 250,
                  child:
                      hotel.logoUrl != null && hotel.logoUrl!.trim().isNotEmpty
                          ? Image.network(
                              hotel.logoUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const _HotelImagePlaceholder();
                              },
                            )
                          : const _HotelImagePlaceholder(),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.nombre,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(
                          hotel.categoriaEstrellas,
                          (index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InformationChip(
                            icon: Icons.schedule,
                            label: 'Entrada ${hotel.horaCheckIn}',
                          ),
                          _InformationChip(
                            icon: Icons.schedule_outlined,
                            label: 'Salida ${hotel.horaCheckOut}',
                          ),
                          _InformationChip(
                            icon: Icons.pets,
                            label: hotel.permiteMascotas
                                ? 'Acepta mascotas'
                                : 'No acepta mascotas',
                          ),
                          _InformationChip(
                            icon: Icons.hotel,
                            label: hotel.estado,
                          ),
                        ],
                      ),
                      if (hotel.descripcion.trim().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Descripción',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hotel.descripcion,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                      const SizedBox(height: 30),
                      Text(
                        'Tipos de habitación',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 14),
                      tiposAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stackTrace) => _ErrorView(
                          message:
                              'No se pudieron cargar los tipos de habitación',
                          onRetry: () {
                            ref.invalidate(
                              tiposHabitacionPorHotelProvider(
                                hotelId,
                              ),
                            );
                          },
                        ),
                        data: (page) {
                          if (page.results.isEmpty) {
                            return const _EmptyTypesView();
                          }

                          return Column(
                            children: page.results.map((tipo) {
                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.bed,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tipo.nombre,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            if (tipo.descripcion
                                                .trim()
                                                .isNotEmpty) ...[
                                              const SizedBox(
                                                height: 6,
                                              ),
                                              Text(
                                                tipo.descripcion,
                                              ),
                                            ],
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                _SmallLabel(
                                                  icon: Icons.people,
                                                  text:
                                                      '${tipo.capacidad} personas',
                                                ),
                                                _SmallLabel(
                                                  icon: Icons.check_circle,
                                                  text: tipo.estado,
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
                            }).toList(),
                          );
                        },
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

class _HotelImagePlaceholder extends StatelessWidget {
  const _HotelImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.hotel,
          size: 90,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _InformationChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InformationChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
      ),
      label: Text(label),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallLabel({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }
}

class _EmptyTypesView extends StatelessWidget {
  const _EmptyTypesView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.bed_outlined,
            size: 52,
          ),
          SizedBox(height: 12),
          Text(
            'Este hotel todavía no tiene tipos de habitación registrados.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
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
