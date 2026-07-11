import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReservationCartState {
  final List<int> roomIds;

  const ReservationCartState({
    this.roomIds = const [],
  });

  int get totalItems => roomIds.length;

  ReservationCartState copyWith({
    List<int>? roomIds,
  }) {
    return ReservationCartState(
      roomIds: roomIds ?? this.roomIds,
    );
  }
}

class ReservationCartNotifier extends StateNotifier<ReservationCartState> {
  ReservationCartNotifier() : super(const ReservationCartState());

  void addRoom(int roomId) {
    if (state.roomIds.contains(roomId)) {
      return;
    }

    state = state.copyWith(
      roomIds: [
        ...state.roomIds,
        roomId,
      ],
    );
  }

  void removeRoom(int roomId) {
    state = state.copyWith(
      roomIds: state.roomIds.where((id) => id != roomId).toList(),
    );
  }

  void clear() {
    state = const ReservationCartState();
  }
}

final reservationCartProvider =
    StateNotifierProvider<ReservationCartNotifier, ReservationCartState>(
  (ref) {
    return ReservationCartNotifier();
  },
);
