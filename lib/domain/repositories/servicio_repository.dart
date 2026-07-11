import '../models/servicio.dart';

abstract class ServicioRepository {
  Future<ServicioPage> obtenerServicios({
    String? buscar,
    bool? activo,
  });

  Future<Servicio> obtenerServicio(
    int servicioId,
  );
}
