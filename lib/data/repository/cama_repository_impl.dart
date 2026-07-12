import '../../domain/model/cama.dart';
import '../../domain/repository/cama_repository.dart';
import '../remote/api/cama_remote_datasource.dart';

class CamaRepositoryImpl implements CamaRepository {
  final CamaRemoteDatasource remoteDatasource;

  const CamaRepositoryImpl({
    required this.remoteDatasource,
  });

  @override
  Future<PaginatedCamas> getCamas({
    int page = 1,
    String? search,
    String? estado,
  }) {
    return remoteDatasource.getCamas(
      page: page,
      search: search,
      estado: estado,
    );
  }

  @override
  Future<Cama> getCamaById(int id) {
    return remoteDatasource.getCamaById(id);
  }
}
