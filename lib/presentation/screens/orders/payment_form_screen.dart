import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/error/api_exception.dart';
import '../../../domain/model/pago.dart';
import '../../../domain/model/reserva.dart';
import '../../../theme/app_colors.dart';
import '../../providers/billing_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/price_summary.dart';
import '../../widgets/status_badge.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  const PaymentFormScreen({
    super.key,
    required this.reservationId,
  });

  final int reservationId;

  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  MetodoPago _selectedMethod = MetodoPago.tarjeta;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(Reserva reservation) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final request = PagoRequest(
      reservaId: reservation.id,
      metodoPago: _selectedMethod,
      monto: double.parse(_amountController.text.trim()),
      estado: PagoEstado.aprobado,
      referencia: _referenceController.text.trim(),
      observaciones: _notesController.text.trim(),
    );

    final pago =
        await ref.read(billingControllerProvider.notifier).crearPago(request);

    if (!mounted) {
      return;
    }

    if (pago == null) {
      final state = ref.read(billingControllerProvider);
      final error = state.hasError ? state.error : null;

      setState(() {
        _errorMessage = error is ApiException
            ? error.message
            : 'No se pudo registrar el pago.';
      });

      return;
    }

    ref.invalidate(
      reservaDetailProvider(reservation.id),
    );
    ref.invalidate(reservasProvider);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Pago registrado correctamente'),
        ),
      );

    context.go('/pagos/${pago.id}');
  }

  @override
  Widget build(BuildContext context) {
    final reservationAsync = ref.watch(
      reservaDetailProvider(widget.reservationId),
    );

    final actionState = ref.watch(
      billingControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar pago'),
      ),
      body: reservationAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _ErrorState(
          onRetry: () {
            ref.invalidate(
              reservaDetailProvider(widget.reservationId),
            );
          },
        ),
        data: (reservation) {
          if (_amountController.text.isEmpty) {
            _amountController.text = reservation.total.toStringAsFixed(2);
          }

          final cannotPay = reservation.estado == ReservaEstado.cancelada ||
              reservation.estado == ReservaEstado.finalizada;

          if (cannotPay) {
            return _UnavailablePayment(
              status: reservation.estado,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReservationPaymentHeader(
                    reservation: reservation,
                  ),
                  const SizedBox(height: 20),
                  PriceSummary(
                    subtotal: reservation.subtotal,
                    taxes: reservation.impuestos,
                    discount: reservation.descuento,
                    total: reservation.total,
                    title: 'Total de la reserva',
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Método de pago',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MetodoPago>(
                    initialValue: _selectedMethod,
                    decoration: const InputDecoration(
                      labelText: 'Selecciona un método',
                      prefixIcon: Icon(Icons.wallet_outlined),
                    ),
                    items: MetodoPago.values.map((method) {
                      return DropdownMenuItem<MetodoPago>(
                        value: method,
                        child: Text(method.label),
                      );
                    }).toList(),
                    onChanged: actionState.isLoading
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedMethod = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    enabled: !actionState.isLoading,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      prefixText: r'$ ',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(
                        value?.trim() ?? '',
                      );

                      if (amount == null || amount <= 0) {
                        return 'Ingresa un monto válido';
                      }

                      if (amount > reservation.total) {
                        return 'El monto supera el total de la reserva';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _referenceController,
                    enabled: !actionState.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Referencia (opcional)',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    enabled: !actionState.isLoading,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones (opcional)',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.errorSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.infoSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.info,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Versión académica: el pago se procesa '
                            'inmediatamente y genera la factura.',
                            style: TextStyle(
                              color: AppColors.info,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: actionState.isLoading
                          ? null
                          : () => _submit(reservation),
                      icon: actionState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.lock_rounded),
                      label: Text(
                        actionState.isLoading
                            ? 'Procesando...'
                            : 'Confirmar pago',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReservationPaymentHeader extends StatelessWidget {
  const _ReservationPaymentHeader({
    required this.reservation,
  });

  final Reserva reservation;

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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hotel_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.codigo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  NumberFormat.currency(
                    locale: 'en_US',
                    symbol: r'$',
                  ).format(reservation.total),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ReservationStatusBadge(
            status: reservation.estado,
          ),
        ],
      ),
    );
  }
}

class _UnavailablePayment extends StatelessWidget {
  const _UnavailablePayment({
    required this.status,
  });

  final ReservaEstado status;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.money_off_rounded,
              size: 70,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 18),
            Text(
              'Esta reserva no admite pagos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ReservationStatusBadge(
              status: status,
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
