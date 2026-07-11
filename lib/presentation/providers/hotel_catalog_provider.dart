import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/hotel.dart';
import '../../domain/repository/hotel_repository.dart';
import 'hotel_provider.dart';

class HotelCatalogState {
  final List<Hotel> hotels;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int total;
  final bool hasMore;
  final String search;
  final int? selectedStars;
  final bool onlyPetFriendly;
  final String estado;
  final int page;

  const HotelCatalogState({
    this.hotels = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.total = 0,
    this.hasMore = false,
    this.search = '',
    this.selectedStars,
    this.onlyPetFriendly = false,
    this.estado = '',
    this.page = 1,
  });

  HotelCatalogState copyWith({
    List<Hotel>? hotels,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? total,
    bool? hasMore,
    String? search,
    int? selectedStars,
    bool clearStars = false,
    bool? onlyPetFriendly,
    String? estado,
    int? page,
  }) {
    return HotelCatalogState(
      hotels: hotels ?? this.hotels,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      search: search ?? this.search,
      selectedStars: clearStars ? null : selectedStars ?? this.selectedStars,
      onlyPetFriendly: onlyPetFriendly ?? this.onlyPetFriendly,
      estado: estado ?? this.estado,
      page: page ?? this.page,
    );
  }
}

class HotelCatalogNotifier extends StateNotifier<HotelCatalogState> {
  HotelCatalogNotifier(this._repository) : super(const HotelCatalogState()) {
    load();
  }

  final HotelRepository _repository;

  Future<void> load({
    bool reset = true,
  }) async {
    final currentState = state;
    final requestedPage = reset ? 1 : currentState.page;

    if (reset) {
      state = currentState.copyWith(
        isLoading: true,
        isLoadingMore: false,
        page: 1,
        error: null,
      );
    } else {
      if (currentState.isLoadingMore || !currentState.hasMore) {
        return;
      }

      state = currentState.copyWith(
        isLoadingMore: true,
        error: null,
      );
    }

    try {
      final result = await _repository.getHoteles(
        page: requestedPage,
        search: currentState.search.isEmpty ? null : currentState.search,
        estado: currentState.estado.isEmpty ? null : currentState.estado,
        categoriaEstrellas: currentState.selectedStars,
        permiteMascotas: currentState.onlyPetFriendly ? true : null,
      );

      state = state.copyWith(
        hotels: reset
            ? result.results
            : [
                ...state.hotels,
                ...result.results,
              ],
        total: result.count,
        hasMore: result.next != null,
        isLoading: false,
        isLoadingMore: false,
        page: requestedPage + 1,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: error.toString(),
      );
    }
  }

  void setSearch(String value) {
    state = state.copyWith(
      search: value.trim(),
    );

    load();
  }

  void setStars(int? stars) {
    state = stars == null
        ? state.copyWith(
            clearStars: true,
          )
        : state.copyWith(
            selectedStars: stars,
          );

    load();
  }

  void setPetFriendly(bool value) {
    state = state.copyWith(
      onlyPetFriendly: value,
    );

    load();
  }

  void setEstado(String value) {
    state = state.copyWith(
      estado: value,
    );

    load();
  }

  void loadMore() {
    load(reset: false);
  }

  void refresh() {
    load();
  }
}

final hotelCatalogProvider =
    StateNotifierProvider<HotelCatalogNotifier, HotelCatalogState>(
  (ref) {
    return HotelCatalogNotifier(
      ref.watch(hotelRepositoryProvider),
    );
  },
);
