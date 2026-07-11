import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/hotel_catalog_provider.dart';
import '../../widgets/hotel_card.dart';

class HotelCatalogScreen extends ConsumerStatefulWidget {
  const HotelCatalogScreen({super.key});

  @override
  ConsumerState<HotelCatalogScreen> createState() {
    return _HotelCatalogScreenState();
  }
}

class _HotelCatalogScreenState extends ConsumerState<HotelCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _onScroll,
    );
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(
            hotelCatalogProvider.notifier,
          )
          .loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(
      const Duration(milliseconds: 500),
      () {
        ref
            .read(
              hotelCatalogProvider.notifier,
            )
            .setSearch(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hotelCatalogProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hoteles',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        '${state.total} hoteles',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Buscar hoteles...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 8,
                          ),
                          child: ChoiceChip(
                            label: const Text('Todos'),
                            selected: state.selectedStars == null,
                            onSelected: (_) {
                              ref
                                  .read(
                                    hotelCatalogProvider.notifier,
                                  )
                                  .setStars(null);
                            },
                          ),
                        ),
                        for (final stars in [3, 4, 5])
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8,
                            ),
                            child: ChoiceChip(
                              label: Text('$stars ★'),
                              selected: state.selectedStars == stars,
                              onSelected: (_) {
                                ref
                                    .read(
                                      hotelCatalogProvider.notifier,
                                    )
                                    .setStars(stars);
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 8,
                          ),
                          child: FilterChip(
                            avatar: const Icon(
                              Icons.pets,
                              size: 18,
                            ),
                            label: const Text(
                              'Mascotas',
                            ),
                            selected: state.onlyPetFriendly,
                            onSelected: (value) {
                              ref
                                  .read(
                                    hotelCatalogProvider.notifier,
                                  )
                                  .setPetFriendly(
                                    value,
                                  );
                            },
                          ),
                        ),
                        ChoiceChip(
                          label: const Text('Activos'),
                          selected: state.estado == 'ACTIVO',
                          onSelected: (selected) {
                            ref
                                .read(
                                  hotelCatalogProvider.notifier,
                                )
                                .setEstado(
                                  selected ? 'ACTIVO' : '',
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading && state.hotels.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.error != null && state.hotels.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.error!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
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
                    );
                  }

                  if (state.hotels.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No se encontraron hoteles',
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref
                          .read(
                            hotelCatalogProvider.notifier,
                          )
                          .refresh();
                    },
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount:
                          state.hotels.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.hotels.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final hotel = state.hotels[index];

                        return HotelCard(
                          hotel: hotel,
                          onTap: () {
                            context.push(
                              '/hoteles/${hotel.id}',
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
