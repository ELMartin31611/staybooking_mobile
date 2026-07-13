import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/pago.dart';
import '../../theme/app_colors.dart';
import '../providers/billing_provider.dart';
import 'status_badge.dart';

class ReservationBillingSection extends ConsumerWidget {
  const ReservationBillingSection({
    super.key,
    required this.reservationId,
    required this.canPay,
  });

  final int reservationId;
  final bool canPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(
      pagosReservaProvider(reservationId),
    );

    final invoicesAsync = ref.watch(
      facturasReservaProvider(reservationId),
    );

    final payments = paymentsAsync.asData?.value ?? [];

    final hasApprovedPayment = payments.any(
      (payment) => payment.estado == PagoEstado.aprobado,
    );

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pagos y facturación',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          paymentsAsync.when(
            loading: () => const _LoadingRow(
              label: 'Consultando pagos...',
            ),
            error: (error, stackTrace) => _ErrorRow(
              label: 'No se pudieron consultar los pagos',
              onRetry: () {
                ref.invalidate(
                  pagosReservaProvider(reservationId),
                );
              },
            ),
            data: (paymentList) {
              if (paymentList.isEmpty) {
                return const _EmptyInformation(
                  icon: Icons.payments_outlined,
                  title: 'Pago pendiente',
                  description:
                      'Esta reserva todavía no tiene pagos registrados.',
                );
              }

              final lastPayment = paymentList.first;

              return _InformationCard(
                icon: Icons.payments_rounded,
                title: '${paymentList.length} pago(s) registrado(s)',
                description: 'Último pago registrado',
                trailing: PaymentStatusBadge(
                  status: lastPayment.estado,
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          invoicesAsync.when(
            loading: () => const _LoadingRow(
              label: 'Consultando facturas...',
            ),
            error: (error, stackTrace) => _ErrorRow(
              label: 'No se pudieron consultar las facturas',
              onRetry: () {
                ref.invalidate(
                  facturasReservaProvider(reservationId),
                );
              },
            ),
            data: (invoiceList) {
              if (invoiceList.isEmpty) {
                return const _EmptyInformation(
                  icon: Icons.receipt_long_outlined,
                  title: 'Sin factura',
                  description:
                      'La factura se generará cuando se apruebe el pago.',
                );
              }

              final lastInvoice = invoiceList.first;

              return _InformationCard(
                icon: Icons.receipt_long_rounded,
                title: '${invoiceList.length} factura(s) emitida(s)',
                description: 'Factura ${lastInvoice.numeroFactura}',
                trailing: InvoiceStatusBadge(
                  status: lastInvoice.estado,
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          if (canPay && !hasApprovedPayment) ...[
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  context.push(
                    '/reservas/$reservationId/pagar',
                  );
                },
                icon: const Icon(
                  Icons.lock_rounded,
                ),
                label: const Text(
                  'Pagar reserva',
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (hasApprovedPayment)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'El pago de esta reserva fue aprobado.',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: () {
              context.push(
                '/pagos?reserva=$reservationId',
              );
            },
            icon: const Icon(
              Icons.payments_outlined,
            ),
            label: const Text(
              'Ver historial de pagos',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              context.push(
                '/facturas?reserva=$reservationId',
              );
            },
            icon: const Icon(
              Icons.receipt_long_outlined,
            ),
            label: const Text(
              'Ver facturas',
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _EmptyInformation extends StatelessWidget {
  const _EmptyInformation({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({
    required this.label,
    required this.onRetry,
  });

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Reintentar',
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
