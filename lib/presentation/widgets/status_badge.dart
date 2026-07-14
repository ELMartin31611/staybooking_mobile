import 'package:flutter/material.dart';

import '../../domain/model/factura.dart';
import '../../domain/model/pago.dart';
import '../../domain/model/reserva.dart';
import '../../theme/app_colors.dart';

class ReservationStatusBadge extends StatelessWidget {
  const ReservationStatusBadge({
    super.key,
    required this.status,
  });

  final ReservaEstado status;

  String get _label {
    switch (status) {
      case ReservaEstado.pendiente:
        return 'Pendiente';
      case ReservaEstado.confirmada:
        return 'Confirmada';
      case ReservaEstado.cancelada:
        return 'Cancelada';
      case ReservaEstado.finalizada:
        return 'Finalizada';
    }
  }

  IconData get _icon {
    switch (status) {
      case ReservaEstado.pendiente:
        return Icons.schedule_rounded;
      case ReservaEstado.confirmada:
        return Icons.check_circle_outline_rounded;
      case ReservaEstado.cancelada:
        return Icons.cancel_outlined;
      case ReservaEstado.finalizada:
        return Icons.verified_outlined;
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case ReservaEstado.pendiente:
        return AppColors.warningSoft;
      case ReservaEstado.confirmada:
        return AppColors.successSoft;
      case ReservaEstado.cancelada:
        return AppColors.errorSoft;
      case ReservaEstado.finalizada:
        return AppColors.infoSoft;
    }
  }

  Color get _foregroundColor {
    switch (status) {
      case ReservaEstado.pendiente:
        return AppColors.warning;
      case ReservaEstado.confirmada:
        return AppColors.success;
      case ReservaEstado.cancelada:
        return AppColors.error;
      case ReservaEstado.finalizada:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StatusBadge(
      semanticLabel: 'Estado de la reserva: $_label',
      label: _label,
      icon: _icon,
      backgroundColor: _backgroundColor,
      foregroundColor: _foregroundColor,
    );
  }
}

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({
    super.key,
    required this.status,
  });

  final PagoEstado status;

  String get _label {
    switch (status) {
      case PagoEstado.pendiente:
        return 'Pendiente';
      case PagoEstado.aprobado:
        return 'Aprobado';
      case PagoEstado.rechazado:
        return 'Rechazado';
    }
  }

  IconData get _icon {
    switch (status) {
      case PagoEstado.pendiente:
        return Icons.schedule_rounded;
      case PagoEstado.aprobado:
        return Icons.check_circle_outline_rounded;
      case PagoEstado.rechazado:
        return Icons.error_outline_rounded;
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case PagoEstado.pendiente:
        return AppColors.warningSoft;
      case PagoEstado.aprobado:
        return AppColors.successSoft;
      case PagoEstado.rechazado:
        return AppColors.errorSoft;
    }
  }

  Color get _foregroundColor {
    switch (status) {
      case PagoEstado.pendiente:
        return AppColors.warning;
      case PagoEstado.aprobado:
        return AppColors.success;
      case PagoEstado.rechazado:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StatusBadge(
      semanticLabel: 'Estado del pago: $_label',
      label: _label,
      icon: _icon,
      backgroundColor: _backgroundColor,
      foregroundColor: _foregroundColor,
    );
  }
}

class InvoiceStatusBadge extends StatelessWidget {
  const InvoiceStatusBadge({
    super.key,
    required this.status,
  });

  final FacturaEstado status;

  String get _label {
    switch (status) {
      case FacturaEstado.emitida:
        return 'Emitida';
      case FacturaEstado.pagada:
        return 'Pagada';
      case FacturaEstado.anulada:
        return 'Anulada';
    }
  }

  IconData get _icon {
    switch (status) {
      case FacturaEstado.emitida:
        return Icons.receipt_long_outlined;
      case FacturaEstado.pagada:
        return Icons.verified_outlined;
      case FacturaEstado.anulada:
        return Icons.cancel_outlined;
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case FacturaEstado.emitida:
        return AppColors.infoSoft;
      case FacturaEstado.pagada:
        return AppColors.successSoft;
      case FacturaEstado.anulada:
        return AppColors.errorSoft;
    }
  }

  Color get _foregroundColor {
    switch (status) {
      case FacturaEstado.emitida:
        return AppColors.info;
      case FacturaEstado.pagada:
        return AppColors.success;
      case FacturaEstado.anulada:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StatusBadge(
      semanticLabel: 'Estado de la factura: $_label',
      label: _label,
      icon: _icon,
      backgroundColor: _backgroundColor,
      foregroundColor: _foregroundColor,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.semanticLabel,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String semanticLabel;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: foregroundColor.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: foregroundColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
