import '../../domain/model/direccion_hotel.dart';
import '../../domain/model/hotel.dart';
import '../../domain/repository/hotel_repository.dart';
import '../remote/api/hotel_remote_datasource.dart';

class HotelRepositoryImpl implements HotelRepository {
  HotelRepositoryImpl(this._remoteDatasource);

  final HotelRemoteDatasource _remoteDatasource;

  @override
  Future<PaginatedHotels> getHoteles({
    int page = 1,
    String? search,
    String? estado,
    int? categoriaEstrellas,
    bool? permiteMascotas,
  }) {
    return _remoteDatasource.getHoteles(
      page: page,
      search: search,
      estado: estado,
      categoriaEstrellas: categoriaEstrellas,
      permiteMascotas: permiteMascotas,
    );
  }

  @override
  Future<Hotel> getHotelById(int id) {
    return _remoteDatasource.getHotelById(id);
  }

  @override
  Future<PaginatedDireccionesHotel> getDireccionesHotel({
    int? hotelId,
    String? provincia,
    String? ciudad,
  }) {
    return _remoteDatasource.getDireccionesHotel(
      hotelId: hotelId,
      provincia: provincia,
      ciudad: ciudad,
    );
  }
}
