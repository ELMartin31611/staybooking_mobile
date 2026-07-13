import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../../providers/billing_provider.dart';
import '../../widgets/price_summary.dart';
import '../../widgets/status_badge.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  final int invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(
      facturaDetailProvider(invoiceId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de factura'),
      ),
      body: invoiceAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: OutlinedButton.icon(
            onPressed: () {
              ref.invalidate(
                facturaDetailProvider(invoiceId),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ),
        data: (invoice) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 54,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      invoice.numeroFactura,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 8),
                    InvoiceStatusBadge(
                      status: invoice.estado,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _InformationCard(
                children: [
                  _InformationRow(
                    label: 'Cliente',
                    value: invoice.clienteNombre,
                  ),
                  _InformationRow(
                    label: 'Reserva',
                    value: invoice.reservaCodigo,
                  ),
                  _InformationRow(
                    label: 'Emisión',
                    value: DateFormat('dd/MM/yyyy HH:mm').format(
                      invoice.fechaEmision,
                    ),
                  ),
                  _InformationRow(
                    label: 'Entrada',
                    value: DateFormat('dd/MM/yyyy').format(
                      invoice.fechaEntrada,
                    ),
                  ),
                  _InformationRow(
                    label: 'Salida',
                    value: DateFormat('dd/MM/yyyy').format(
                      invoice.fechaSalida,
                    ),
                  ),
                  _InformationRow(
                    label: 'Noches',
                    value: invoice.numeroNoches.toString(),
                  ),
                  if (invoice.metodoPago != null)
                    _InformationRow(
                      label: 'Método',
                      value: invoice.metodoPago!,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              PriceSummary(
                subtotal: invoice.subtotal,
                taxes: invoice.impuestos,
                discount: invoice.descuento,
                total: invoice.total,
                title: 'Valores facturados',
              ),
              if (invoice.descripcion != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    invoice.descripcion!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  context.go(
                    '/reservas/${invoice.reservaId}',
                  );
                },
                icon: const Icon(Icons.hotel_outlined),
                label: const Text('Ver reserva'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
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

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
