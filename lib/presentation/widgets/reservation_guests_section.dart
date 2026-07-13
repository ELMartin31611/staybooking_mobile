import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/huesped_reserva.dart';
import '../../theme/app_colors.dart';

class ReservationGuestsSection extends StatelessWidget {
  const ReservationGuestsSection({
    super.key,
    required this.guests,
    this.onAdd,
  });

  final AsyncValue<List<HuespedReserva>> guests;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.groups_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Huéspedes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            if (onAdd != null)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(
                  Icons.add_rounded,
                ),
                label: const Text('Agregar'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        guests.when(
          loading: () => const SizedBox(
            height: 90,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => const _MessageCard(
            icon: Icons.error_outline_rounded,
            message: 'No se pudieron cargar los huéspedes.',
          ),
          data: (items) {
            if (items.isEmpty) {
              return const _MessageCard(
                icon: Icons.person_add_alt_1_outlined,
                message: 'Todavía no se han registrado huéspedes.',
              );
            }

            return Column(
              children: items.map((guest) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GuestCard(
                    guest: guest,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({
    required this.guest,
  });

  final HuespedReserva guest;

  @override
  Widget build(BuildContext context) {
    final initial = guest.nombres.trim().isEmpty
        ? '?'
        : guest.nombres.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceVariant,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        guest.nombreCompleto,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (guest.esTitular) ...[
                      const SizedBox(width: 7),
                      const Icon(
                        Icons.verified_rounded,
                        size: 17,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${guest.tipoDocumento}: ${guest.numeroDocumento}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
