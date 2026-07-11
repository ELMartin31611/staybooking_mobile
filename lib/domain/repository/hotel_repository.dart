import '../model/direccion_hotel.dart';
import '../model/hotel.dart';

abstract class HotelRepository {
  Future<PaginatedHotels> getHoteles({
    int page = 1,
    String? search,
    String? estado,
    int? categoriaEstrellas,
    bool? permiteMascotas,
  });

  Future<Hotel> getHotelById(int id);

  Future<PaginatedDireccionesHotel> getDireccionesHotel({
    int? hotelId,
    String? provincia,
    String? ciudad,
  });
}
