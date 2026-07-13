import '../../domain/model/factura.dart';
import '../../domain/model/pago.dart';
import '../../domain/repository/billing_repository.dart';
import '../remote/api/billing_remote_datasource.dart';

class BillingRepositoryImpl implements BillingRepository {
  const BillingRepositoryImpl(
    this._remoteDataSource,
  );

  final BillingRemoteDataSource _remoteDataSource;

  @override
  Future<List<Pago>> getPagos({
    int? reservaId,
    MetodoPago? metodoPago,
    PagoEstado? estado,
    String? search,
  }) {
    return _remoteDataSource.getPagos(
      reservaId: reservaId,
      metodoPago: metodoPago,
      estado: estado,
      search: search,
    );
  }

  @override
  Future<Pago> getPagoById(int id) {
    return _remoteDataSource.getPagoById(id);
  }

  @override
  Future<Pago> createPago(
    PagoRequest request,
  ) {
    return _remoteDataSource.createPago(request);
  }

  @override
  Future<Pago> updatePagoEstado(
    int id,
    PagoEstado estado,
  ) {
    return _remoteDataSource.updatePagoEstado(
      id,
      estado,
    );
  }

  @override
  Future<List<Factura>> getFacturas({
    int? reservaId,
    int? clienteId,
    FacturaEstado? estado,
    String? search,
  }) {
    return _remoteDataSource.getFacturas(
      reservaId: reservaId,
      clienteId: clienteId,
      estado: estado,
      search: search,
    );
  }

  @override
  Future<Factura> getFacturaById(int id) {
    return _remoteDataSource.getFacturaById(id);
  }
}
