import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/catalog/cama_list_screen.dart';
import '../screens/catalog/habitacion_detail_screen.dart';
import '../screens/catalog/habitacion_list_screen.dart';
import '../screens/catalog/home_screen.dart';
import '../screens/catalog/hotel_catalog_screen.dart';
import '../screens/catalog/hotel_detail_screen.dart';
import '../screens/catalog/imagen_habitacion_screen.dart';
import '../screens/catalog/tipo_habitacion_cama_screen.dart';
import 'public_shell.dart';

bool _isStaff(AuthState auth) {
  final rol = auth.profile?.rol.toUpperCase() ?? '';

  return const {
    'ADMIN',
    'ADMINISTRADOR',
    'SUPERADMIN',
    'SUPER_ADMIN',
    'STAFF',
    'EMPLEADO',
  }.contains(rol);
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
                  .read(
                    authControllerProvider.notifier,
                  )
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

      final isAuthRoute = location == '/login' || location == '/register';

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
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'Hotel inválido',
                    ),
                  ),
                );
              }

              return HotelDetailScreen(
                hotelId: hotelId,
              );
            },
          ),
          GoRoute(
            path: '/hoteles/:hotelId/tipos-habitacion/:tipoId/habitaciones',
            builder: (context, state) {
              final hotelId = int.tryParse(
                state.pathParameters['hotelId'] ?? '',
              );

              final tipoId = int.tryParse(
                state.pathParameters['tipoId'] ?? '',
              );

              if (hotelId == null || tipoId == null) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'Datos de habitaciones inválidos',
                    ),
                  ),
                );
              }

              final tipoNombre =
                  state.uri.queryParameters['nombre'] ?? 'Habitaciones';

              return HabitacionListScreen(
                hotelId: hotelId,
                tipoHabitacionId: tipoId,
                tipoNombre: tipoNombre,
              );
            },
          ),

          // Debe estar antes de /habitaciones/:id.
          GoRoute(
            path: '/habitaciones/:id/imagenes',
            builder: (context, state) {
              final habitacionId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (habitacionId == null) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'Habitación inválida',
                    ),
                  ),
                );
              }

              return ImagenHabitacionScreen(
                habitacionId: habitacionId,
              );
            },
          ),
          GoRoute(
            path: '/habitaciones/:id',
            builder: (context, state) {
              final habitacionId = int.tryParse(
                state.pathParameters['id'] ?? '',
              );

              if (habitacionId == null) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'Habitación inválida',
                    ),
                  ),
                );
              }

              return HabitacionDetailScreen(
                habitacionId: habitacionId,
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
              final tipoId = int.tryParse(
                state.pathParameters['tipoId'] ?? '',
              );

              if (tipoId == null) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'Tipo de habitación inválido',
                    ),
                  ),
                );
              }

              return TipoHabitacionCamaScreen(
                tipoHabitacionId: tipoId,
              );
            },
          ),
          GoRoute(
            path: '/reservas',
            builder: (context, state) {
              return const _PlaceholderScreen(
                'Mis reservas — próximo módulo',
              );
            },
          ),
          GoRoute(
            path: '/reservas/:id',
            builder: (context, state) {
              return _PlaceholderScreen(
                'Reserva '
                '#${state.pathParameters['id']}',
              );
            },
          ),
          GoRoute(
            path: '/reserva',
            builder: (context, state) {
              return const _PlaceholderScreen(
                'Proceso de reserva — próximo módulo',
              );
            },
          ),
          GoRoute(
            path: '/perfil',
            builder: (context, state) {
              return const _PlaceholderScreen(
                'Mi perfil — próximo módulo',
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) {
          return const _PlaceholderScreen(
            'Dashboard administrativo',
          );
        },
      ),
      GoRoute(
        path: '/admin/hoteles',
        builder: (context, state) {
          return const _PlaceholderScreen(
            'Administrar hoteles',
          );
        },
      ),
      GoRoute(
        path: '/admin/habitaciones',
        builder: (context, state) {
          return const _PlaceholderScreen(
            'Administrar habitaciones',
          );
        },
      ),
      GoRoute(
        path: '/admin/reservas',
        builder: (context, state) {
          return const _PlaceholderScreen(
            'Administrar reservas',
          );
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
