import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../../providers/billing_provider.dart';
import '../../widgets/status_badge.dart';

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({
    super.key,
    required this.paymentId,
  });

  final int paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentAsync = ref.watch(
      pagoDetailProvider(paymentId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del pago'),
      ),
      body: paymentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: OutlinedButton.icon(
            onPressed: () {
              ref.invalidate(
                pagoDetailProvider(paymentId),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ),
        data: (payment) {
          final currency = NumberFormat.currency(
            locale: 'en_US',
            symbol: r'$',
          );

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 62,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      currency.format(payment.monto),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      payment.codigoTransaccion,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: PaymentStatusBadge(
                  status: payment.estado,
                ),
              ),
              const SizedBox(height: 24),
              _DetailCard(
                children: [
                  _DetailRow(
                    label: 'Reserva',
                    value: payment.reservaCodigo,
                  ),
                  _DetailRow(
                    label: 'Método',
                    value: payment.metodoPago.label,
                  ),
                  _DetailRow(
                    label: 'Fecha',
                    value: DateFormat('dd/MM/yyyy HH:mm').format(
                      payment.fechaPago ?? payment.createdAt,
                    ),
                  ),
                  if (payment.referencia != null)
                    _DetailRow(
                      label: 'Referencia',
                      value: payment.referencia!,
                    ),
                  if (payment.observaciones != null)
                    _DetailRow(
                      label: 'Observaciones',
                      value: payment.observaciones!,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  context.push(
                    '/facturas?reserva=${payment.reservaId}',
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Ver factura'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.go(
                    '/reservas/${payment.reservaId}',
                  );
                },
                child: const Text('Volver a la reserva'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
