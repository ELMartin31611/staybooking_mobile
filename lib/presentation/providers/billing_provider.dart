import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:staybooking_mobile/data/repository/billing_repository_impl.dart';

import '../../data/remote/api/billing_remote_datasource.dart';
import '../../domain/model/factura.dart';
import '../../domain/model/pago.dart';
import '../../domain/repository/billing_repository.dart';
import 'auth_provider.dart';

final billingRemoteDataSourceProvider =
    Provider<BillingRemoteDataSource>((ref) {
  return BillingRemoteDataSource(
    ref.watch(authDioProvider),
  );
});

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepositoryImpl(
    ref.watch(billingRemoteDataSourceProvider),
  );
});

final pagosProvider = FutureProvider.autoDispose<List<Pago>>((ref) {
  return ref.watch(billingRepositoryProvider).getPagos();
});

final pagosReservaProvider = FutureProvider.autoDispose.family<List<Pago>, int>(
  (ref, reservaId) {
    return ref.watch(billingRepositoryProvider).getPagos(
          reservaId: reservaId,
        );
  },
);

final pagoDetailProvider = FutureProvider.autoDispose.family<Pago, int>(
  (ref, pagoId) {
    return ref.watch(billingRepositoryProvider).getPagoById(
          pagoId,
        );
  },
);

final facturasProvider = FutureProvider.autoDispose<List<Factura>>((ref) {
  return ref.watch(billingRepositoryProvider).getFacturas();
});

final facturasReservaProvider =
    FutureProvider.autoDispose.family<List<Factura>, int>(
  (ref, reservaId) {
    return ref.watch(billingRepositoryProvider).getFacturas(
          reservaId: reservaId,
        );
  },
);

final facturaDetailProvider = FutureProvider.autoDispose.family<Factura, int>(
  (ref, facturaId) {
    return ref.watch(billingRepositoryProvider).getFacturaById(
          facturaId,
        );
  },
);

class BillingController extends StateNotifier<AsyncValue<void>> {
  BillingController({
    required Ref ref,
    required BillingRepository repository,
  })  : _ref = ref,
        _repository = repository,
        super(const AsyncData(null));

  final Ref _ref;
  final BillingRepository _repository;

  Future<Pago?> crearPago(
    PagoRequest request,
  ) async {
    state = const AsyncLoading();

    try {
      final pago = await _repository.createPago(request);

      state = const AsyncData(null);

      _ref.invalidate(pagosProvider);
      _ref.invalidate(
        pagosReservaProvider(request.reservaId),
      );
      _ref.invalidate(facturasProvider);
      _ref.invalidate(
        facturasReservaProvider(request.reservaId),
      );

      return pago;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return null;
    }
  }

  Future<Pago?> actualizarEstadoPago(
    int pagoId,
    int reservaId,
    PagoEstado estadoPago,
  ) async {
    state = const AsyncLoading();

    try {
      final pago = await _repository.updatePagoEstado(
        pagoId,
        estadoPago,
      );

      state = const AsyncData(null);

      _ref.invalidate(pagosProvider);
      _ref.invalidate(
        pagosReservaProvider(reservaId),
      );
      _ref.invalidate(
        pagoDetailProvider(pagoId),
      );
      _ref.invalidate(facturasProvider);
      _ref.invalidate(
        facturasReservaProvider(reservaId),
      );

      return pago;
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );

      return null;
    }
  }

  void limpiarEstado() {
    state = const AsyncData(null);
  }
}

final billingControllerProvider =
    StateNotifierProvider<BillingController, AsyncValue<void>>((ref) {
  return BillingController(
    ref: ref,
    repository: ref.watch(billingRepositoryProvider),
  );
});
