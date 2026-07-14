import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_hotels_screen.dart';
import '../screens/admin/admin_rooms_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/catalog/cama_list_screen.dart';
import '../screens/catalog/habitacion_detail_screen.dart';
import '../screens/catalog/habitacion_list_screen.dart';
import '../screens/catalog/home_screen.dart';
import '../screens/catalog/hotel_catalog_screen.dart';
import '../screens/catalog/hotel_detail_screen.dart';
import '../screens/catalog/imagen_habitacion_screen.dart';
import '../screens/catalog/servicio_catalog_screen.dart';
import '../screens/catalog/tipo_habitacion_cama_screen.dart';
import '../screens/catalog/tipo_habitacion_servicio_screen.dart';
import '../screens/orders/create_reservation_screen.dart';
import '../screens/orders/guest_form_screen.dart';
import '../screens/orders/invoice_detail_screen.dart';
import '../screens/orders/invoices_screen.dart';
import '../screens/orders/my_reservations_screen.dart';
import '../screens/orders/payment_detail_screen.dart';
import '../screens/orders/payment_form_screen.dart';
import '../screens/orders/payments_screen.dart';
import '../screens/orders/reservation_detail_screen.dart';
import 'public_shell.dart';

bool _isStaff(AuthState auth) {
  final role = auth.profile?.rol.toUpperCase() ?? '';

  return const {
    'ADMIN',
    'ADMINISTRADOR',
    'SUPERADMIN',
    'SUPER_ADMIN',
    'STAFF',
    'EMPLEADO',
  }.contains(role);
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _PlaceholderScreen extends ConsumerWidget {
  const _PlaceholderScreen(this.title);

  final String title;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref
                  .read(authControllerProvider.notifier)
                  .logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(
        authControllerProvider,
      );

      final location = state.matchedLocation;

      if (auth.isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      final isAuthRoute =
          location == '/login' || location == '/register';

      final isSplash = location == '/splash';

      if (isSplash) {
        if (!auth.isAuthenticated) {
          return '/login';
        }

        return _isStaff(auth) ? '/admin' : '/';
      }

      if (!auth.isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (auth.isAuthenticated && isAuthRoute) {
        return _isStaff(auth) ? '/admin' : '/';
      }

      if (auth.isAuthenticated &&
          !_isStaff(auth) &&
          location.startsWith('/admin')) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) {
          return const _SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      ShellRoute(
        builder: (
          context,
          state,
          child,
        ) {
          return PublicShell(
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return const HomeScreen();
            },
          ),
          GoRoute(
            path: '/hoteles',
            builder: (context, state) {
              return const HotelCatalogScreen();
            },
          ),
          GoRoute(
            path: '/hoteles/:id',
            builder: (context, state) {
              final hotelId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (hotelId == null) {
                return const _InvalidRouteScreen(
                  message: 'Hotel inválido',
                );
              }

              return HotelDetailScreen(
                hotelId: hotelId,
              );
            },
          ),
          GoRoute(
            path:
                '/hoteles/:hotelId/tipos-habitacion/:tipoId/habitaciones',
            builder: (context, state) {
              final hotelId = int.tryParse(
                state.pathParameters['hotelId'] ?? '',
              );

              final roomTypeId = int.tryParse(
                state.pathParameters['tipoId'] ?? '',
              );

              if (hotelId == null || roomTypeId == null) {
                return const _InvalidRouteScreen(
                  message: 'Los datos de las habitaciones son inválidos',
                );
              }

              final roomTypeName =
                  state.uri.queryParameters['nombre'] ??
                      'Habitaciones';

              return HabitacionListScreen(
                hotelId: hotelId,
                tipoHabitacionId: roomTypeId,
                tipoNombre: roomTypeName,
              );
            },
          ),
          GoRoute(
            path: '/habitaciones/:id/imagenes',
            builder: (context, state) {
              final roomId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (roomId == null) {
                return const _InvalidRouteScreen(
                  message: 'Habitación inválida',
                );
              }

              return ImagenHabitacionScreen(
                habitacionId: roomId,
              );
            },
          ),
          GoRoute(
            path: '/habitaciones/:id',
            builder: (context, state) {
              final roomId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (roomId == null) {
                return const _InvalidRouteScreen(
                  message: 'Habitación inválida',
                );
              }

              return HabitacionDetailScreen(
                habitacionId: roomId,
              );
            },
          ),
          GoRoute(
            path: '/camas',
            builder: (context, state) {
              return const CamaListScreen();
            },
          ),
          GoRoute(
            path: '/tipos-habitacion/:tipoId/camas',
            builder: (context, state) {
              final roomTypeId = int.tryParse(
                state.pathParameters['tipoId'] ?? '',
              );

              if (roomTypeId == null) {
                return const _InvalidRouteScreen(
                  message: 'Tipo de habitación inválido',
                );
              }

              return TipoHabitacionCamaScreen(
                tipoHabitacionId: roomTypeId,
              );
            },
          ),
          GoRoute(
            path: '/servicios',
            builder: (context, state) {
              return const ServicioCatalogScreen();
            },
          ),
          GoRoute(
            path: '/tipos-habitacion/:tipoId/servicios',
            builder: (context, state) {
              final roomTypeId = int.tryParse(
                state.pathParameters['tipoId'] ?? '',
              );

              if (roomTypeId == null) {
                return const _InvalidRouteScreen(
                  message: 'Tipo de habitación inválido',
                );
              }

              return TipoHabitacionServicioScreen(
                tipoHabitacionId: roomTypeId,
              );
            },
          ),
          GoRoute(
            path: '/reservas',
            builder: (context, state) {
              return const MyReservationsScreen();
            },
          ),
          GoRoute(
            path: '/reservas/:id/huespedes/nuevo',
            builder: (context, state) {
              final reservationId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (reservationId == null) {
                return const _InvalidRouteScreen(
                  message: 'Reserva inválida',
                );
              }

              return GuestFormScreen(
                reservationId: reservationId,
              );
            },
          ),
          GoRoute(
            path: '/reservas/:id/pagar',
            builder: (context, state) {
              final reservationId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (reservationId == null) {
                return const _InvalidRouteScreen(
                  message: 'Reserva inválida',
                );
              }

              return PaymentFormScreen(
                reservationId: reservationId,
              );
            },
          ),
          GoRoute(
            path: '/reservas/:id',
            builder: (context, state) {
              final reservationId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (reservationId == null) {
                return const _InvalidRouteScreen(
                  message: 'Reserva inválida',
                );
              }

              return ReservationDetailScreen(
                reservationId: reservationId,
              );
            },
          ),
          GoRoute(
            path: '/reserva',
            builder: (context, state) {
              return const CreateReservationScreen();
            },
          ),
          GoRoute(
            path: '/pagos',
            builder: (context, state) {
              return const PaymentsScreen();
            },
          ),
          GoRoute(
            path: '/pagos/:id',
            builder: (context, state) {
              final paymentId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (paymentId == null) {
                return const _InvalidRouteScreen(
                  message: 'Pago inválido',
                );
              }

              return PaymentDetailScreen(
                paymentId: paymentId,
              );
            },
          ),
          GoRoute(
            path: '/facturas',
            builder: (context, state) {
              return const InvoicesScreen();
            },
          ),
          GoRoute(
            path: '/facturas/:id',
            builder: (context, state) {
              final invoiceId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (invoiceId == null) {
                return const _InvalidRouteScreen(
                  message: 'Factura inválida',
                );
              }

              return InvoiceDetailScreen(
                invoiceId: invoiceId,
              );
            },
          ),
          GoRoute(
            path: '/perfil',
            builder: (context, state) {
              return const ProfileScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) {
          return const AdminDashboardScreen();
        },
      ),
      GoRoute(
        path: '/admin/hoteles',
        builder: (context, state) {
          return const AdminHotelsScreen();
        },
      ),
      GoRoute(
        path: '/admin/habitaciones',
        builder: (context, state) {
          return const AdminRoomsScreen();
        },
      ),
      GoRoute(
        path: '/admin/reservas',
        builder: (context, state) {
          return const MyReservationsScreen();
        },
      ),
      GoRoute(
        path: '/admin/usuarios',
        builder: (context, state) {
          return const _PlaceholderScreen(
            'Administrar usuarios',
          );
        },
      ),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}