import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/hotel_catalog_provider.dart';
import '../../widgets/hotel_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final catalogState = ref.watch(hotelCatalogProvider);

    final featuredHotels = catalogState.hotels.take(4).toList();

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                72,
                24,
                48,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Encuentra tu',
                    style: textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'próxima estadía',
                    style: textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Explora hoteles y encuentra '
                    'el alojamiento perfecto para ti.',
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      context.go('/hoteles');
                    },
                    icon: const Icon(
                      Icons.travel_explore,
                    ),
                    label: const Text('Ver hoteles'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                12,
              ),
              child: Text(
                'Búsquedas rápidas',
                style: textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.star),
                    label: const Text('5 estrellas'),
                    onPressed: () {
                      ref
                          .read(
                            hotelCatalogProvider.notifier,
                          )
                          .setStars(5);

                      context.go('/hoteles');
                    },
                  ),
                  const SizedBox(width: 10),
                  ActionChip(
                    avatar: const Icon(Icons.star),
                    label: const Text('4 estrellas'),
                    onPressed: () {
                      ref
                          .read(
                            hotelCatalogProvider.notifier,
                          )
                          .setStars(4);

                      context.go('/hoteles');
                    },
                  ),
                  const SizedBox(width: 10),
                  ActionChip(
                    avatar: const Icon(Icons.pets),
                    label: const Text('Con mascotas'),
                    onPressed: () {
                      ref
                          .read(
                            hotelCatalogProvider.notifier,
                          )
                          .setPetFriendly(true);

                      context.go('/hoteles');
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hoteles destacados',
                    style: textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/hoteles');
                    },
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
            ),
          ),
          if (catalogState.isLoading && featuredHotels.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (catalogState.error != null && featuredHotels.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          catalogState.error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            ref
                                .read(
                                  hotelCatalogProvider.notifier,
                                )
                                .refresh();
                          },
                          child: const Text(
                            'Reintentar',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else if (featuredHotels.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No existen hoteles disponibles.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final hotel = featuredHotels[index];

                    return HotelCard(
                      hotel: hotel,
                      onTap: () {
                        context.push(
                          '/hoteles/${hotel.id}',
                        );
                      },
                    );
                  },
                  childCount: featuredHotels.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}
