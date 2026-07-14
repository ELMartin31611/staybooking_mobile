import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/remote/api/admin_remote_datasource.dart';
import '../../data/remote/api/imagen_habitacion_remote_datasource.dart';
import '../../domain/model/habitacion.dart';
import '../../domain/model/hotel.dart';
import '../../domain/model/tipo_habitacion.dart';
import 'auth_provider.dart';
import 'habitacion_provider.dart';
import 'hotel_provider.dart';
import 'imagen_habitacion_provider.dart';
import 'tipo_habitacion_provider.dart';

final adminRemoteDataSourceProvider =
    Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource(
    ref.watch(authDioProvider),
  );
});

final adminHotelsProvider =
    FutureProvider.autoDispose<List<Hotel>>((ref) async {
  return ref.watch(adminRemoteDataSourceProvider).getHotels();
});

final adminRoomsProvider =
    FutureProvider.autoDispose<List<Habitacion>>((ref) async {
  return ref.watch(adminRemoteDataSourceProvider).getRooms();
});

final adminRoomTypesProvider =
    FutureProvider.autoDispose<List<TipoHabitacion>>((ref) async {
  return ref.watch(adminRemoteDataSourceProvider).getRoomTypes();
});

class AdminController extends StateNotifier<AsyncValue<void>> {
  AdminController({
    required Ref ref,
    required AdminRemoteDataSource remoteDataSource,
    required ImagenHabitacionRemoteDatasource imageDataSource,
  })  : _ref = ref,
        _remoteDataSource = remoteDataSource,
        _imageDataSource = imageDataSource,
        super(const AsyncData(null));

  final Ref _ref;
  final AdminRemoteDataSource _remoteDataSource;
  final ImagenHabitacionRemoteDatasource _imageDataSource;

  Future<bool> createHotel(
    Map<String, dynamic> data, {
    required XFile logo,
  }) async {
    return _execute(
      request: () async {
        await _remoteDataSource.createHotel(
          data,
          logo: logo,
        );
      },
      onSuccess: _invalidateHotels,
    );
  }

  Future<bool> updateHotel(
    int hotelId,
    Map<String, dynamic> data, {
    XFile? logo,
  }) async {
    return _execute(
      request: () async {
        await _remoteDataSource.updateHotel(
          hotelId,
          data,
          logo: logo,
        );
      },
      onSuccess: () {
        _invalidateHotels();
        _ref.invalidate(hotelDetalleProvider(hotelId));
      },
    );
  }

  Future<bool> deleteHotel(int hotelId) async {
    return _execute(
      request: () => _remoteDataSource.deleteHotel(hotelId),
      onSuccess: () {
        _invalidateHotels();
        _ref.invalidate(hotelDetalleProvider(hotelId));
      },
    );
  }

  Future<bool> createRoom(
    Map<String, dynamic> data, {
    required XFile image,
  }) async {
    return _execute(
      request: () async {
        final room = await _remoteDataSource.createRoom(data);

        await _imageDataSource.uploadImagenHabitacion(
          habitacionId: room.id,
          image: image,
          titulo: 'Imagen principal de la habitación',
          descripcion: 'Imagen subida por el administrador.',
          orden: 1,
          esPrincipal: true,
        );
      },
      onSuccess: () {
        _invalidateRooms();
      },
    );
  }

  Future<bool> updateRoom(
    int roomId,
    Map<String, dynamic> data,
  ) async {
    return _execute(
      request: () async {
        await _remoteDataSource.updateRoom(roomId, data);
      },
      onSuccess: () {
        _invalidateRooms();
        _ref.invalidate(habitacionDetalleProvider(roomId));
      },
    );
  }

  Future<bool> deleteRoom(int roomId) async {
    return _execute(
      request: () => _remoteDataSource.deleteRoom(roomId),
      onSuccess: () {
        _invalidateRooms();
        _ref.invalidate(habitacionDetalleProvider(roomId));
      },
    );
  }

  Future<bool> createRoomType(
    Map<String, dynamic> data,
  ) async {
    return _execute(
      request: () async {
        await _remoteDataSource.createRoomType(data);
      },
      onSuccess: _invalidateRoomTypes,
    );
  }

  Future<bool> updateRoomType(
    int typeId,
    Map<String, dynamic> data,
  ) async {
    return _execute(
      request: () async {
        await _remoteDataSource.updateRoomType(typeId, data);
      },
      onSuccess: _invalidateRoomTypes,
    );
  }

  Future<bool> deleteRoomType(int typeId) async {
    return _execute(
      request: () => _remoteDataSource.deleteRoomType(typeId),
      onSuccess: _invalidateRoomTypes,
    );
  }

  Future<bool> _execute({
    required Future<void> Function() request,
    required void Function() onSuccess,
  }) async {
    if (state.isLoading) {
      return false;
    }

    state = const AsyncLoading();

    try {
      await request();
      onSuccess();
      state = const AsyncData(null);

      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return false;
    }
  }

  void _invalidateHotels() {
    _ref.invalidate(adminHotelsProvider);
    _ref.invalidate(hotelesProvider);
  }

  void _invalidateRooms() {
    _ref.invalidate(adminRoomsProvider);
    _ref.invalidate(habitacionesProvider);
    _ref.invalidate(imagenesHabitacionProvider);
  }

  void _invalidateRoomTypes() {
    _ref.invalidate(adminRoomTypesProvider);
    _ref.invalidate(tiposHabitacionProvider);
  }

  void clearState() {
    state = const AsyncData(null);
  }
}

final adminControllerProvider =
    StateNotifierProvider<AdminController, AsyncValue<void>>((ref) {
  return AdminController(
    ref: ref,
    remoteDataSource: ref.watch(
      adminRemoteDataSourceProvider,
    ),
    imageDataSource: ref.watch(
      imagenHabitacionRemoteDatasourceProvider,
    ),
  );
});