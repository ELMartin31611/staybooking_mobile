import '../model/cama.dart';

abstract class CamaRepository {
  Future<PaginatedCamas> getCamas({
    int page = 1,
    String? search,
    String? estado,
  });

  Future<Cama> getCamaById(int id);
}
