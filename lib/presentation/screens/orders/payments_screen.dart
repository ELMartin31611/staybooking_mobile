import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/model/pago.dart';
import '../../../theme/app_colors.dart';
import '../../providers/billing_provider.dart';
import '../../widgets/status_badge.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({
    super.key,
    this.reservationId,
  });

  final int? reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Pago>> paymentsAsync = reservationId == null
        ? ref.watch(pagosProvider)
        : ref.watch(pagosReservaProvider(reservationId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          reservationId == null ? 'Mis pagos' : 'Pagos de la reserva',
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () {
              if (reservationId == null) {
                ref.invalidate(pagosProvider);
              } else {
                ref.invalidate(
                  pagosReservaProvider(reservationId!),
                );
              }
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: paymentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          onRetry: () {
            if (reservationId == null) {
              ref.invalidate(pagosProvider);
            } else {
              ref.invalidate(
                pagosReservaProvider(reservationId!),
              );
            }
          },
        ),
        data: (payments) {
          if (payments.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (reservationId == null) {
                ref.invalidate(pagosProvider);
                await ref.read(pagosProvider.future);
              } else {
                ref.invalidate(
                  pagosReservaProvider(reservationId!),
                );
                await ref.read(
                  pagosReservaProvider(reservationId!).future,
                );
              }
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: payments.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 14);
              },
              itemBuilder: (context, index) {
                return _PaymentCard(
                  payment: payments[index],
                  onTap: () {
                    context.push(
                      '/pagos/${payments[index].id}',
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.onTap,
  });

  final Pago payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
    );

    final date = payment.fechaPago ?? payment.createdAt;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.codigoTransaccion,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reserva ${payment.reservaCodigo}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currency.format(payment.monto),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  PaymentStatusBadge(status: payment.estado),
                  const Spacer(),
                  Text(
                    '${payment.metodoPago.label} · '
                    '${DateFormat('dd/MM/yyyy').format(date)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 72,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 18),
            Text(
              'Todavía no existen pagos',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los pagos de tus reservas aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Reintentar'),
      ),
    );
  }
}
