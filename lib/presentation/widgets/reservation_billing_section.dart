import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../providers/billing_provider.dart';

class ReservationBillingSection extends ConsumerWidget {
  const ReservationBillingSection({
    super.key,
    required this.reservationId,
  });

  final int reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(
      pagosReservaProvider(reservationId),
    );

    final invoicesAsync = ref.watch(
      facturasReservaProvider(reservationId),
    );

    final payments = paymentsAsync.asData?.value;
    final invoices = invoicesAsync.asData?.value;

    final paymentId =
        payments != null && payments.isNotEmpty ? payments.first.id : null;

    final invoiceId =
        invoices != null && invoices.isNotEmpty ? invoices.first.id : null;

    final isLoading = paymentsAsync.isLoading || invoicesAsync.isLoading;

    final hasError = paymentsAsync.hasError || invoicesAsync.hasError;

    return Container(
      width: double.infinity,
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pago y facturación',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Comprobantes de esta reserva',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Actualizar',
                onPressed: () {
                  ref.invalidate(
                    pagosReservaProvider(reservationId),
                  );
                  ref.invalidate(
                    facturasReservaProvider(reservationId),
                  );
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (isLoading && payments == null && invoices == null)
            const SizedBox(
              height: 70,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (hasError && payments == null && invoices == null)
            _BillingMessage(
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              backgroundColor: AppColors.errorSoft,
              message: 'No se pudo consultar el pago o la factura.',
              actionLabel: 'Reintentar',
              onAction: () {
                ref.invalidate(
                  pagosReservaProvider(reservationId),
                );
                ref.invalidate(
                  facturasReservaProvider(reservationId),
                );
              },
            )
          else if (paymentId == null && invoiceId == null)
            const _BillingMessage(
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
              backgroundColor: AppColors.warningSoft,
              message: 'La reserva todavía no tiene un pago aprobado.',
            )
          else ...[
            _BillingMessage(
              icon: Icons.verified_rounded,
              color: AppColors.success,
              backgroundColor: AppColors.successSoft,
              message: invoiceId != null
                  ? 'Pago aprobado y factura generada correctamente.'
                  : 'El pago fue registrado correctamente.',
            ),
            if (paymentId != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(
                      '/pagos/$paymentId',
                    );
                  },
                  icon: const Icon(
                    Icons.payments_outlined,
                  ),
                  label: const Text(
                    'Ver comprobante de pago',
                  ),
                ),
              ),
            ],
            if (invoiceId != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    context.push(
                      '/facturas/$invoiceId',
                    );
                  },
                  icon: const Icon(
                    Icons.receipt_long_rounded,
                  ),
                  label: const Text(
                    'Ver factura de compra',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _BillingMessage extends StatelessWidget {
  const _BillingMessage({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: color,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
