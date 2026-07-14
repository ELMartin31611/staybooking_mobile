import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/reservation_cart_provider.dart';

class PublicShell extends ConsumerWidget {
  const PublicShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final reservationCount = ref.watch(reservationCartProvider).totalItems;

    final role =
        ref.watch(authControllerProvider).profile?.rol.toUpperCase() ?? '';

    final isStaff = const {
      'ADMIN',
      'ADMINISTRADOR',
      'SUPERADMIN',
      'SUPER_ADMIN',
      'STAFF',
      'EMPLEADO',
    }.contains(role);

    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex() {
      if (location.startsWith('/hoteles')) {
        return 1;
      }

      if (location.startsWith('/reservas') ||
          location.startsWith('/pagos') ||
          location.startsWith('/facturas')) {
        return 2;
      }

      if (location.startsWith('/reserva')) {
        return 3;
      }

      if (location.startsWith('/perfil')) {
        return 4;
      }

      if (isStaff && location.startsWith('/admin')) {
        return 5;
      }

      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex(),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.hotel_outlined),
            activeIcon: Icon(Icons.hotel),
            label: 'Hoteles',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.event_available_outlined),
                if (reservationCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        reservationCount > 99
                            ? '99+'
                            : reservationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.event_available),
            label: 'Reserva',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          if (isStaff)
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.admin_panel_settings_outlined,
              ),
              activeIcon: Icon(
                Icons.admin_panel_settings_rounded,
              ),
              label: 'Dashboard',
            ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/hoteles');
              break;
            case 2:
              context.go('/reservas');
              break;
            case 3:
              context.go('/reserva');
              break;
            case 4:
              context.go('/perfil');
              break;
            case 5:
              if (isStaff) {
                context.go('/admin');
              }
              break;
          }
        },
      ),
    );
  }
}
