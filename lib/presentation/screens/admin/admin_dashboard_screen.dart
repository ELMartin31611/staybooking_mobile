import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/reservation_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(adminHotelsProvider);
    ref.invalidate(adminRoomsProvider);
    ref.invalidate(reservasProvider);
    ref.invalidate(pagosProvider);
    ref.invalidate(facturasProvider);

    await Future.wait([
      ref.read(adminHotelsProvider.future),
      ref.read(adminRoomsProvider.future),
      ref.read(reservasProvider.future),
      ref.read(pagosProvider.future),
      ref.read(facturasProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final hotelsAsync = ref.watch(adminHotelsProvider);
    final roomsAsync = ref.watch(adminRoomsProvider);
    final reservationsAsync = ref.watch(reservasProvider);
    final paymentsAsync = ref.watch(pagosProvider);
    final invoicesAsync = ref.watch(facturasProvider);

    final role = auth.profile?.rol.toUpperCase() ?? 'ADMIN';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administración'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () {
              _refresh(ref);
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            40,
          ),
          children: [
            _WelcomeCard(role: role),
            const SizedBox(height: 24),
            Text(
              'Resumen general',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 4 : 2;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: constraints.maxWidth >= 900 ? 1.55 : 1.25,
                  children: [
                    _StatCard(
                      title: 'Hoteles',
                      value: hotelsAsync.asData?.value.length,
                      icon: Icons.apartment_rounded,
                      color: AppColors.primary,
                    ),
                    _StatCard(
                      title: 'Habitaciones',
                      value: roomsAsync.asData?.value.length,
                      icon: Icons.bed_rounded,
                      color: AppColors.info,
                    ),
                    _StatCard(
                      title: 'Reservas',
                      value: reservationsAsync.asData?.value.length,
                      icon: Icons.calendar_month_rounded,
                      color: AppColors.warning,
                    ),
                    _StatCard(
                      title: 'Facturas',
                      value: invoicesAsync.asData?.value.length,
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.success,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Gestión rápida',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 14),
            _AdminActionCard(
              icon: Icons.apartment_rounded,
              title: 'Administrar hoteles',
              subtitle: 'Crear, editar y eliminar hoteles',
              onTap: () {
                context.push('/admin/hoteles');
              },
            ),
            const SizedBox(height: 12),
            _AdminActionCard(
              icon: Icons.bed_rounded,
              title: 'Administrar habitaciones',
              subtitle: 'Gestionar habitaciones y disponibilidad',
              onTap: () {
                context.push('/admin/habitaciones');
              },
            ),
            const SizedBox(height: 12),
            _AdminActionCard(
              icon: Icons.calendar_month_rounded,
              title: 'Gestionar reservas',
              subtitle: 'Consultar las reservas realizadas',
              onTap: () {
                context.push('/admin/reservas');
              },
            ),
            const SizedBox(height: 12),
            _AdminActionCard(
              icon: Icons.payments_rounded,
              title: 'Consultar pagos',
              subtitle:
                  '${paymentsAsync.asData?.value.length ?? 0} pagos registrados',
              onTap: () {
                context.push('/pagos');
              },
            ),
            const SizedBox(height: 12),
            _AdminActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'Consultar facturas',
              subtitle:
                  '${invoicesAsync.asData?.value.length ?? 0} facturas emitidas',
              onTap: () {
                context.push('/facturas');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.role,
  });

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel de control',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sesión iniciada como $role',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final int? value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
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
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const Spacer(),
          Text(
            value?.toString() ?? '—',
            style: TextStyle(
              color: color,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
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
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
