import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/model/habitacion.dart';
import '../../../domain/model/reserva.dart';
import '../../../domain/model/reserva_habitacion.dart';
import '../../../domain/model/tarifa_habitacion.dart';
import '../../../theme/app_colors.dart';
import '../../providers/rate_provider.dart';
import '../../providers/reservation_cart_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/price_summary.dart';

class CreateReservationScreen extends ConsumerStatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  ConsumerState<CreateReservationScreen> createState() {
    return _CreateReservationScreenState();
  }
}

class _CreateReservationScreenState
    extends ConsumerState<CreateReservationScreen> {
  static const double _taxRate = 0.12;
  static const double _childRatePercentage = 0.50;

  final _notesController = TextEditingController();

  DateTimeRange? _dateRange;
  int _adults = 1;
  int _children = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _nights {
    final range = _dateRange;

    if (range == null) {
      return 0;
    }

    return range.end.difference(range.start).inDays;
  }

  TarifaHabitacion? _findRate(
    Habitacion room,
    List<TarifaHabitacion> rates,
  ) {
    final roomTypeId = room.tipoHabitacionId;

    if (roomTypeId == null) {
      return null;
    }

    for (final rate in rates) {
      if (rate.tipoHabitacionId == roomTypeId && rate.isActive) {
        return rate;
      }
    }

    return null;
  }

  double _baseNightlyPrice(
    List<Habitacion> rooms,
    List<TarifaHabitacion> rates,
  ) {
    return rooms.fold<double>(0, (total, room) {
      final rate = _findRate(room, rates);

      return total + (rate?.precioNoche ?? 0);
    });
  }

  double _baseStayPrice(
    List<Habitacion> rooms,
    List<TarifaHabitacion> rates,
  ) {
    if (_nights <= 0) {
      return 0;
    }

    return _baseNightlyPrice(rooms, rates) * _nights;
  }

  double _adultSubtotal(
    List<Habitacion> rooms,
    List<TarifaHabitacion> rates,
  ) {
    return _baseStayPrice(rooms, rates) * _adults;
  }

  double _childrenSubtotal(
    List<Habitacion> rooms,
    List<TarifaHabitacion> rates,
  ) {
    return _baseStayPrice(rooms, rates) * _children * _childRatePercentage;
  }

  double _subtotal(
    List<Habitacion> rooms,
    List<TarifaHabitacion> rates,
  ) {
    return _adultSubtotal(rooms, rates) + _childrenSubtotal(rooms, rates);
  }

  Future<void> _selectDates() async {
    final today = DateUtils.dateOnly(DateTime.now());

    final selectedRange = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(
        today.year + 2,
        today.month,
        today.day,
      ),
      initialDateRange: _dateRange,
      helpText: 'Selecciona tu estadía',
      saveText: 'Guardar fechas',
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );

    if (selectedRange == null || !mounted) {
      return;
    }

    setState(() {
      _dateRange = selectedRange;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final range = _dateRange;

    if (range == null || _nights <= 0) {
      _showMessage(
        'Selecciona las fechas de entrada y salida.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final client = await ref.read(
        currentClienteProvider.future,
      );

      if (!mounted) {
        return;
      }

      if (client == null) {
        _showMessage(
          'Completa tus datos de cliente antes de reservar.',
        );
        return;
      }

      final rooms = await ref.read(
        selectedReservationRoomsProvider.future,
      );

      final rates = await ref.read(
        tarifasHabitacionProvider.future,
      );

      if (!mounted) {
        return;
      }

      if (rooms.isEmpty) {
        _showMessage(
          'Selecciona al menos una habitación.',
        );
        return;
      }

      for (final room in rooms) {
        if (_findRate(room, rates) == null) {
          _showMessage(
            'No encontramos una tarifa activa para la '
            'habitación ${room.numero}.',
          );
          return;
        }
      }

      final subtotal = _subtotal(rooms, rates);
      final taxes = subtotal * _taxRate;
      final total = subtotal + taxes;

      final repository = ref.read(
        reservationRepositoryProvider,
      );

      final reservation = await repository.createReserva(
        ReservaRequest(
          clienteId: client.id,
          fechaEntrada: range.start,
          fechaSalida: range.end,
          cantidadAdultos: _adults,
          cantidadNinos: _children,
          subtotal: subtotal,
          impuestos: taxes,
          descuento: 0,
          total: total,
          observaciones: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ),
      );

      for (final room in rooms) {
        final rate = _findRate(room, rates)!;

        await repository.createReservaHabitacion(
          ReservaHabitacionRequest(
            reservaId: reservation.id,
            habitacionId: room.id,
            tarifaId: rate.id,
          ),
        );
      }

      ref
          .read(
            reservationCartProvider.notifier,
          )
          .clear();

      ref.invalidate(reservasProvider);

      ref.invalidate(
        reservaDetailProvider(reservation.id),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Reserva creada correctamente',
            ),
          ),
        );

      context.go(
        '/reservas/${reservation.id}',
      );
    } catch (_) {
      if (mounted) {
        _showMessage(
          'No se pudo crear la reserva. Inténtalo nuevamente.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(
      selectedReservationRoomsProvider,
    );

    final ratesAsync = ref.watch(
      tarifasHabitacionProvider,
    );

    final clientAsync = ref.watch(
      currentClienteProvider,
    );

    final rooms = roomsAsync.asData?.value ?? const <Habitacion>[];

    final rates = ratesAsync.asData?.value ?? const <TarifaHabitacion>[];

    final nightlyPrice = _baseNightlyPrice(
      rooms,
      rates,
    );

    final stayPrice = _baseStayPrice(
      rooms,
      rates,
    );

    final adultsSubtotal = _adultSubtotal(
      rooms,
      rates,
    );

    final childrenSubtotal = _childrenSubtotal(
      rooms,
      rates,
    );

    final subtotal = adultsSubtotal + childrenSubtotal;
    final taxes = subtotal * _taxRate;
    final total = subtotal + taxes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirma tu reserva',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            130,
          ),
          children: [
            if (clientAsync.hasValue && clientAsync.value == null) ...[
              _ClientWarning(
                onCompleteProfile: () {
                  context.go('/perfil');
                },
              ),
              const SizedBox(height: 18),
            ],
            _DateSelector(
              range: _dateRange,
              nights: _nights,
              onTap: _selectDates,
            ),
            const SizedBox(height: 18),
            _GuestCounterCard(
              adults: _adults,
              childrenCount: _children,
              onAdultsChanged: (value) {
                setState(() {
                  _adults = value;
                });
              },
              onChildrenChanged: (value) {
                setState(() {
                  _children = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Habitaciones seleccionadas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            roomsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => const _SimpleMessage(
                icon: Icons.error_outline_rounded,
                message: 'No pudimos cargar las habitaciones.',
              ),
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyRooms(
                    onExplore: () {
                      context.go('/hoteles');
                    },
                  );
                }

                return Column(
                  children: items.map((room) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: _SelectedRoomCard(
                        room: room,
                        rate: _findRate(
                          room,
                          rates,
                        ),
                        nights: _nights,
                        adults: _adults,
                        childrenCount: _children,
                        onRemove: () {
                          ref
                              .read(
                                reservationCartProvider.notifier,
                              )
                              .removeRoom(room.id);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                hintText: 'Llegada tardía, solicitudes especiales...',
                alignLabelWithHint: true,
                prefixIcon: Icon(
                  Icons.notes_rounded,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _PriceCalculationCard(
              nightlyPrice: nightlyPrice,
              nights: _nights,
              stayPrice: stayPrice,
              adults: _adults,
              adultsSubtotal: adultsSubtotal,
              childrenCount: _children,
              childrenSubtotal: childrenSubtotal,
            ),
            const SizedBox(height: 18),
            PriceSummary(
              subtotal: subtotal,
              taxes: taxes,
              discount: 0,
              total: total,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            16,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.divider,
              ),
            ),
          ),
          child: FilledButton.icon(
            onPressed: rooms.isEmpty || _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surface,
                    ),
                  )
                : const Icon(
                    Icons.lock_outline_rounded,
                  ),
            label: Text(
              _isSubmitting ? 'Creando reserva...' : 'Confirmar reserva',
            ),
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.range,
    required this.nights,
    required this.onTap,
  });

  final DateTimeRange? range;
  final int nights;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final selectedRange = range;

    final dateText = selectedRange == null
        ? 'Selecciona entrada y salida'
        : '${formatter.format(selectedRange.start)} → '
            '${formatter.format(selectedRange.end)} · '
            '$nights noches';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fechas de la estadía',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestCounterCard extends StatelessWidget {
  const _GuestCounterCard({
    required this.adults,
    required this.childrenCount,
    required this.onAdultsChanged,
    required this.onChildrenChanged,
  });

  final int adults;
  final int childrenCount;
  final ValueChanged<int> onAdultsChanged;
  final ValueChanged<int> onChildrenChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _CounterRow(
            title: 'Adultos',
            subtitle: 'Tarifa completa por persona',
            value: adults,
            minimum: 1,
            onChanged: onAdultsChanged,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Divider(),
          ),
          _CounterRow(
            title: 'Niños',
            subtitle: 'Pagan el 50% de la tarifa',
            value: childrenCount,
            minimum: 0,
            onChanged: onChildrenChanged,
          ),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.minimum,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final int value;
  final int minimum;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton.outlined(
          onPressed: value > minimum
              ? () {
                  onChanged(value - 1);
                }
              : null,
          icon: const Icon(
            Icons.remove_rounded,
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton.outlined(
          onPressed: value < 20
              ? () {
                  onChanged(value + 1);
                }
              : null,
          icon: const Icon(
            Icons.add_rounded,
          ),
        ),
      ],
    );
  }
}

class _SelectedRoomCard extends StatelessWidget {
  const _SelectedRoomCard({
    required this.room,
    required this.rate,
    required this.nights,
    required this.adults,
    required this.childrenCount,
    required this.onRemove,
  });

  final Habitacion room;
  final TarifaHabitacion? rate;
  final int nights;
  final int adults;
  final int childrenCount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final currentRate = rate;
    final adultNightPrice = currentRate?.precioNoche ?? 0;
    final childNightPrice = adultNightPrice * 0.50;

    final adultTotal = adultNightPrice * nights * adults;

    final childrenTotal = childNightPrice * nights * childrenCount;

    final total = adultTotal + childrenTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.bed_rounded,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habitación ${room.numero}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                if (currentRate == null)
                  const Text(
                    'Tarifa no disponible',
                    style: TextStyle(
                      color: AppColors.error,
                    ),
                  )
                else ...[
                  Text(
                    '\$${adultNightPrice.toStringAsFixed(2)} '
                    'adulto/noche · '
                    '\$${childNightPrice.toStringAsFixed(2)} '
                    'niño/noche',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (nights > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$nights noches · Total '
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Quitar habitación',
            onPressed: onRemove,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCalculationCard extends StatelessWidget {
  const _PriceCalculationCard({
    required this.nightlyPrice,
    required this.nights,
    required this.stayPrice,
    required this.adults,
    required this.adultsSubtotal,
    required this.childrenCount,
    required this.childrenSubtotal,
  });

  final double nightlyPrice;
  final int nights;
  final double stayPrice;
  final int adults;
  final double adultsSubtotal;
  final int childrenCount;
  final double childrenSubtotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: AppColors.primary,
              ),
              SizedBox(width: 9),
              Text(
                'Cálculo de la estadía',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CalculationRow(
            label: '\$${nightlyPrice.toStringAsFixed(2)} × $nights noches',
            value: '\$${stayPrice.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _CalculationRow(
            label: '$adults ${adults == 1 ? 'adulto' : 'adultos'} × 100%',
            value: '\$${adultsSubtotal.toStringAsFixed(2)}',
          ),
          if (childrenCount > 0) ...[
            const SizedBox(height: 10),
            _CalculationRow(
              label:
                  '$childrenCount ${childrenCount == 1 ? 'niño' : 'niños'} × 50%',
              value: '\$${childrenSubtotal.toStringAsFixed(2)}',
            ),
          ],
        ],
      ),
    );
  }
}

class _CalculationRow extends StatelessWidget {
  const _CalculationRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyRooms extends StatelessWidget {
  const _EmptyRooms({
    required this.onExplore,
  });

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return _SimpleMessage(
      icon: Icons.bed_outlined,
      message: 'Aún no seleccionaste habitaciones.',
      action: TextButton(
        onPressed: onExplore,
        child: const Text(
          'Explorar hoteles',
        ),
      ),
    );
  }
}

class _ClientWarning extends StatelessWidget {
  const _ClientWarning({
    required this.onCompleteProfile,
  });

  final VoidCallback onCompleteProfile;

  @override
  Widget build(BuildContext context) {
    return _SimpleMessage(
      icon: Icons.person_outline_rounded,
      message: 'Completa tus datos de cliente antes de confirmar la reserva.',
      action: TextButton(
        onPressed: onCompleteProfile,
        child: const Text(
          'Completar perfil',
        ),
      ),
    );
  }
}

class _SimpleMessage extends StatelessWidget {
  const _SimpleMessage({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 8),
            action!,
          ],
        ],
      ),
    );
  }
}
