import '../model/factura.dart';
import '../model/pago.dart';

abstract class BillingRepository {
  Future<List<Pago>> getPagos({
    int? reservaId,
    MetodoPago? metodoPago,
    PagoEstado? estado,
    String? search,
  });

  Future<Pago> getPagoById(int id);

  Future<Pago> createPago(PagoRequest request);

  Future<Pago> updatePagoEstado(
    int id,
    PagoEstado estado,
  );

  Future<List<Factura>> getFacturas({
    int? reservaId,
    int? clienteId,
    FacturaEstado? estado,
    String? search,
  });

  Future<Factura> getFacturaById(int id);
}
