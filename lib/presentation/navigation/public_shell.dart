import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex() {
      if (location.startsWith('/hoteles')) {
        return 1;
      }

      if (location.startsWith('/reservas')) {
        return 2;
      }

      if (location.startsWith('/reserva')) {
        return 3;
      }

      if (location.startsWith('/perfil')) {
        return 4;
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
                const Icon(
                  Icons.event_available_outlined,
                ),
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
          }
        },
      ),
    );
  }
}
