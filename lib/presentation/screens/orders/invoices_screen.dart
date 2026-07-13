import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/model/factura.dart';
import '../../../theme/app_colors.dart';
import '../../providers/billing_provider.dart';
import '../../widgets/status_badge.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({
    super.key,
    this.reservationId,
  });

  final int? reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Factura>> invoicesAsync = reservationId == null
        ? ref.watch(facturasProvider)
        : ref.watch(facturasReservaProvider(reservationId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          reservationId == null ? 'Mis facturas' : 'Factura de la reserva',
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () {
              if (reservationId == null) {
                ref.invalidate(facturasProvider);
              } else {
                ref.invalidate(
                  facturasReservaProvider(reservationId!),
                );
              }
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: invoicesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: OutlinedButton.icon(
            onPressed: () {
              if (reservationId == null) {
                ref.invalidate(facturasProvider);
              } else {
                ref.invalidate(
                  facturasReservaProvider(reservationId!),
                );
              }
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const _EmptyInvoices();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: invoices.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 14);
            },
            itemBuilder: (context, index) {
              final invoice = invoices[index];

              return _InvoiceCard(
                invoice: invoice,
                onTap: () {
                  context.push(
                    '/facturas/${invoice.id}',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.onTap,
  });

  final Factura invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
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
                  const Icon(
                    Icons.receipt_long_rounded,
                    size: 42,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.numeroFactura,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.reservaCodigo,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_US',
                      symbol: r'$',
                    ).format(invoice.total),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  InvoiceStatusBadge(status: invoice.estado),
                  const Spacer(),
                  Text(
                    DateFormat('dd/MM/yyyy').format(
                      invoice.fechaEmision,
                    ),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
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

class _EmptyInvoices extends StatelessWidget {
  const _EmptyInvoices();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 72,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 18),
            Text(
              'Todavía no existen facturas',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'La factura se generará cuando completes un pago.',
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
