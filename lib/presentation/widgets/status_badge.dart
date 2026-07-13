import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Estado de la reserva: $_label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 16,
              color: _foregroundColor,
            ),
            const SizedBox(width: 6),
            Text(
              _label,
              style: TextStyle(
                color: _foregroundColor,
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
