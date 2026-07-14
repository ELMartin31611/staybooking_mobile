import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/model/reserva.dart';
import '../../../theme/app_colors.dart';
import '../../providers/billing_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/price_summary.dart';
import '../../widgets/reservation_billing_section.dart';
import '../../widgets/reservation_guests_section.dart';
import '../../widgets/reservation_rooms_section.dart';
import '../../widgets/status_badge.dart';

class ReservationDetailScreen extends ConsumerWidget {
  const ReservationDetailScreen({
    super.key,
    required this.reservationId,
  });

  final int reservationId;

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(
      reservaDetailProvider(reservationId),
    );

    ref.invalidate(
      reservaHabitacionesProvider(reservationId),
    );

    ref.invalidate(
      huespedesReservaProvider(reservationId),
    );

    ref.invalidate(
      pagosReservaProvider(reservationId),
    );

    ref.invalidate(
      facturasReservaProvider(reservationId),
    );

    await ref.read(
      reservaDetailProvider(reservationId).future,
    );
  }

  Future<void> _cancelReservation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar reserva'),
          content: const Text(
            '¿Estás seguro de que deseas cancelar esta reserva?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text(
                'Cancelar reserva',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(reservationRepositoryProvider).updateReservaEstado(
            reservationId,
            ReservaEstado.cancelada,
          );

      ref.invalidate(
        reservaDetailProvider(reservationId),
      );

      ref.invalidate(reservasProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reserva cancelada correctamente',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo cancelar la reserva',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationAsync = ref.watch(
      reservaDetailProvider(reservationId),
    );

    final roomsAsync = ref.watch(
      reservaHabitacionesProvider(reservationId),
    );

    final guestsAsync = ref.watch(
      huespedesReservaProvider(reservationId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de reserva'),
      ),
      body: reservationAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _DetailError(
          onRetry: () {
            ref.invalidate(
              reservaDetailProvider(reservationId),
            );
          },
        ),
        data: (reservation) {
          final maximumGuests =
              reservation.cantidadAdultos + reservation.cantidadNinos;

          final registeredGuests = guestsAsync.asData?.value.length;

          final guestsAreComplete =
              registeredGuests != null && registeredGuests == maximumGuests;

          final guestsExceeded =
              registeredGuests != null && registeredGuests > maximumGuests;

          final isPending = reservation.estado == ReservaEstado.pendiente;

          final canAddGuests = isPending &&
              registeredGuests != null &&
              registeredGuests < maximumGuests;

          final canCancel = isPending;

          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                36,
              ),
              children: [
                _ReservationHeader(
                  reservation: reservation,
                ),
                const SizedBox(height: 16),
                _StayInformation(
                  checkIn: _formatDate(
                    reservation.fechaEntrada,
                  ),
                  checkOut: _formatDate(
                    reservation.fechaSalida,
                  ),
                  nights: reservation.numeroNoches,
                  adults: reservation.cantidadAdultos,
                  childrenCount: reservation.cantidadNinos,
                ),
                const SizedBox(height: 24),
                ReservationRoomsSection(
                  rooms: roomsAsync,
                ),
                const SizedBox(height: 24),
                ReservationGuestsSection(
                  guests: guestsAsync,
                  onAdd: canAddGuests
                      ? () {
                          context.push(
                            '/reservas/'
                            '$reservationId/'
                            'huespedes/nuevo',
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 12),
                _GuestCapacityCard(
                  registeredGuests: registeredGuests,
                  maximumGuests: maximumGuests,
                  exceeded: guestsExceeded,
                ),
                const SizedBox(height: 24),
                PriceSummary(
                  subtotal: reservation.subtotal,
                  taxes: reservation.impuestos,
                  discount: reservation.descuento,
                  total: reservation.total,
                ),
                if (isPending) ...[
                  const SizedBox(height: 24),
                  _PendingPaymentCard(
                    registeredGuests: registeredGuests,
                    maximumGuests: maximumGuests,
                    guestsAreComplete: guestsAreComplete,
                    guestsExceeded: guestsExceeded,
                    total: reservation.total,
                    onPay: guestsAreComplete && !guestsExceeded
                        ? () {
                            context.push(
                              '/reservas/'
                              '$reservationId/pagar',
                            );
                          }
                        : null,
                  ),
                ],
                const SizedBox(height: 24),
                ReservationBillingSection(
                  reservationId: reservation.id,
                ),
                if (reservation.observaciones?.trim().isNotEmpty ?? false) ...[
                  const SizedBox(height: 24),
                  _NotesCard(
                    notes: reservation.observaciones!,
                  ),
                ],
                if (canCancel) ...[
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _cancelReservation(
                          context,
                          ref,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(
                          color: AppColors.error,
                        ),
                      ),
                      icon: const Icon(
                        Icons.cancel_outlined,
                      ),
                      label: const Text(
                        'Cancelar reserva',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReservationHeader extends StatelessWidget {
  const _ReservationHeader({
    required this.reservation,
  });

  final Reserva reservation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.hotel_class_rounded,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.codigo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      reservation.clienteNombre,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ReservationStatusBadge(
            status: reservation.estado,
          ),
        ],
      ),
    );
  }
}

class _StayInformation extends StatelessWidget {
  const _StayInformation({
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.adults,
    required this.childrenCount,
  });

  final String checkIn;
  final String checkOut;
  final int nights;
  final int adults;
  final int childrenCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateItem(
                  label: 'Llegada',
                  value: checkIn,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppColors.divider,
              ),
              Expanded(
                child: _DateItem(
                  label: 'Salida',
                  value: checkOut,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 18,
            ),
            child: Divider(),
          ),
          Row(
            children: [
              const Icon(
                Icons.dark_mode_outlined,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 9),
              Text(
                '$nights '
                '${nights == 1 ? 'noche' : 'noches'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.group_outlined,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  '$adults '
                  '${adults == 1 ? 'adulto' : 'adultos'}'
                  '${childrenCount > 0 ? ', '
                      '$childrenCount '
                      '${childrenCount == 1 ? 'niño' : 'niños'}' : ''}',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  const _DateItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _GuestCapacityCard extends StatelessWidget {
  const _GuestCapacityCard({
    required this.registeredGuests,
    required this.maximumGuests,
    required this.exceeded,
  });

  final int? registeredGuests;
  final int maximumGuests;
  final bool exceeded;

  @override
  Widget build(BuildContext context) {
    if (registeredGuests == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 11),
            Text(
              'Comprobando cupos de huéspedes...',
            ),
          ],
        ),
      );
    }

    final isComplete = registeredGuests == maximumGuests;

    final color = exceeded
        ? AppColors.error
        : isComplete
            ? AppColors.success
            : AppColors.info;

    final backgroundColor = exceeded
        ? AppColors.errorSoft
        : isComplete
            ? AppColors.successSoft
            : AppColors.infoSoft;

    final message = exceeded
        ? 'Hay más huéspedes registrados que cupos comprados.'
        : isComplete
            ? 'Cupo completo: '
                '$registeredGuests de $maximumGuests huéspedes.'
            : 'Huéspedes registrados: '
                '$registeredGuests de $maximumGuests.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            exceeded
                ? Icons.error_outline_rounded
                : isComplete
                    ? Icons.check_circle_rounded
                    : Icons.groups_outlined,
            color: color,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  const _PendingPaymentCard({
    required this.registeredGuests,
    required this.maximumGuests,
    required this.guestsAreComplete,
    required this.guestsExceeded,
    required this.total,
    required this.onPay,
  });

  final int? registeredGuests;
  final int maximumGuests;
  final bool guestsAreComplete;
  final bool guestsExceeded;
  final double total;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    String message;

    if (registeredGuests == null) {
      message = 'Estamos comprobando los huéspedes registrados.';
    } else if (guestsExceeded) {
      message = 'Corrige la cantidad de huéspedes antes de pagar.';
    } else if (!guestsAreComplete) {
      final missing = maximumGuests - registeredGuests!;

      message = 'Falta registrar $missing '
          '${missing == 1 ? 'huésped' : 'huéspedes'} '
          'antes de pagar.';
    } else {
      message = 'Todos los huéspedes están registrados. '
          'Puedes completar el pago.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: guestsAreComplete && !guestsExceeded
              ? AppColors.primary
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                'Completar compra',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Total a pagar',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                NumberFormat.currency(
                  locale: 'en_US',
                  symbol: r'$',
                  decimalDigits: 2,
                ).format(total),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: onPay,
              icon: const Icon(
                Icons.payment_rounded,
              ),
              label: const Text(
                'Pagar reserva',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({
    required this.notes,
  });

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notes_rounded,
                color: AppColors.primary,
              ),
              SizedBox(width: 9),
              Text(
                'Observaciones',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notes,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 18),
            Text(
              'No pudimos cargar la reserva',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
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
