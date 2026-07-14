import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/model/tarifa_habitacion.dart';
import '../../../theme/app_colors.dart';
import '../../providers/hotel_provider.dart';
import '../../providers/rate_provider.dart';
import '../../providers/tipo_habitacion_provider.dart';

class HotelDetailScreen extends ConsumerWidget {
  const HotelDetailScreen({
    super.key,
    required this.hotelId,
  });

  final int hotelId;

  TarifaHabitacion? _findRate(
    int roomTypeId,
    List<TarifaHabitacion> rates,
  ) {
    for (final rate in rates) {
      if (rate.tipoHabitacionId == roomTypeId && rate.isActive) {
        return rate;
      }
    }

    return null;
  }

  void _openRooms(
    BuildContext context, {
    required int roomTypeId,
    required String roomTypeName,
  }) {
    final location = Uri(
      path:
          '/hoteles/$hotelId/tipos-habitacion/$roomTypeId/habitaciones',
      queryParameters: {
        'nombre': roomTypeName,
      },
    );

    context.push(location.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelAsync = ref.watch(
      hotelDetalleProvider(hotelId),
    );

    final roomTypesAsync = ref.watch(
      tiposHabitacionPorHotelProvider(hotelId),
    );

    final ratesAsync = ref.watch(
      tarifasHabitacionProvider,
    );

    final rates =
        ratesAsync.asData?.value ?? const <TarifaHabitacion>[];

    return Scaffold(
      backgroundColor: AppColors.background,
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
            ref.invalidate(
              hotelDetalleProvider(hotelId),
            );

            ref.invalidate(
              tiposHabitacionPorHotelProvider(hotelId),
            );

            ref.invalidate(
              tarifasHabitacionProvider,
            );
          },
        ),
        data: (hotel) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                hotelDetalleProvider(hotelId),
              );

              ref.invalidate(
                tiposHabitacionPorHotelProvider(hotelId),
              );

              ref.invalidate(
                tarifasHabitacionProvider,
              );

              await ref.read(
                hotelDetalleProvider(hotelId).future,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                bottom: 36,
              ),
              children: [
                SizedBox(
                  height: 260,
                  child:
                      hotel.logoUrl != null &&
                              hotel.logoUrl!.trim().isNotEmpty
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
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      _HotelStars(
                        stars: hotel.categoriaEstrellas,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InformationChip(
                            icon: Icons.login_rounded,
                            label: 'Entrada ${hotel.horaCheckIn}',
                          ),
                          _InformationChip(
                            icon: Icons.logout_rounded,
                            label: 'Salida ${hotel.horaCheckOut}',
                          ),
                          _InformationChip(
                            icon: Icons.pets_outlined,
                            label: hotel.permiteMascotas
                                ? 'Acepta mascotas'
                                : 'No acepta mascotas',
                          ),
                          _InformationChip(
                            icon: Icons.verified_outlined,
                            label: hotel.estado,
                          ),
                        ],
                      ),
                      if (hotel.descripcion.trim().isNotEmpty) ...[
                        const SizedBox(height: 26),
                        Text(
                          'Descripción',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hotel.descripcion,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tipos de habitación',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          const Icon(
                            Icons.bed_rounded,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Selecciona un tipo para consultar sus habitaciones.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      roomTypesAsync.when(
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
                            children: page.results.map((roomType) {
                              final rate = _findRate(
                                roomType.id,
                                rates,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 14,
                                ),
                                child: _RoomTypeCard(
                                  name: roomType.nombre,
                                  description: roomType.descripcion,
                                  capacity: roomType.capacidad,
                                  status: roomType.estado,
                                  rate: rate,
                                  rateLoading: ratesAsync.isLoading,
                                  onOpenRooms: () {
                                    _openRooms(
                                      context,
                                      roomTypeId: roomType.id,
                                      roomTypeName: roomType.nombre,
                                    );
                                  },
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

class _RoomTypeCard extends StatelessWidget {
  const _RoomTypeCard({
    required this.name,
    required this.description,
    required this.capacity,
    required this.status,
    required this.rate,
    required this.rateLoading,
    required this.onOpenRooms,
  });

  final String name;
  final String description;
  final int capacity;
  final String status;
  final TarifaHabitacion? rate;
  final bool rateLoading;
  final VoidCallback onOpenRooms;

  @override
  Widget build(BuildContext context) {
    final currentRate = rate;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpenRooms,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.king_bed_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        if (description.trim().isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SmallLabel(
                    icon: Icons.people_alt_outlined,
                    text: capacity == 1
                        ? '1 persona'
                        : '$capacity personas',
                  ),
                  _SmallLabel(
                    icon: Icons.check_circle_outline_rounded,
                    text: status,
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: Divider(),
              ),
              if (rateLoading)
                const Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Consultando tarifa...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              else if (currentRate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentRate.moneda} '
                      '${currentRate.precioNoche.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Precio por noche',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              else
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sin tarifa activa',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Debe registrarse una tarifa en el backend.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: onOpenRooms,
                  icon: const Icon(
                    Icons.search_rounded,
                  ),
                  label: const Text(
                    'Ver habitaciones',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotelStars extends StatelessWidget {
  const _HotelStars({
    required this.stars,
  });

  final int stars;

  @override
  Widget build(BuildContext context) {
    final validStars = stars.clamp(0, 5).toInt();

    return Row(
      children: [
        ...List.generate(
          validStars,
          (index) => const Padding(
            padding: EdgeInsets.only(
              right: 2,
            ),
            child: Icon(
              Icons.star_rounded,
              color: AppColors.star,
              size: 24,
            ),
          ),
        ),
        if (validStars == 0)
          const Text(
            'Sin categoría',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          )
        else ...[
          const SizedBox(width: 7),
          Text(
            '$validStars ${validStars == 1 ? 'estrella' : 'estrellas'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _HotelImagePlaceholder extends StatelessWidget {
  const _HotelImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySoft,
      child: const Center(
        child: Icon(
          Icons.hotel_rounded,
          size: 90,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _InformationChip extends StatelessWidget {
  const _InformationChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: AppColors.primary,
      ),
      label: Text(label),
      backgroundColor: AppColors.surface,
      side: const BorderSide(
        color: AppColors.border,
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.bed_outlined,
            size: 52,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'Este hotel todavía no tiene tipos de habitación registrados.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
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