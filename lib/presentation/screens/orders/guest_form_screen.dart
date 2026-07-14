import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/api_exception.dart';
import '../../../domain/model/huesped_reserva.dart';
import '../../../domain/model/reserva.dart';
import '../../../theme/app_colors.dart';
import '../../providers/reservation_provider.dart';

class GuestFormScreen extends ConsumerStatefulWidget {
  const GuestFormScreen({
    super.key,
    required this.reservationId,
  });

  final int reservationId;

  @override
  ConsumerState<GuestFormScreen> createState() {
    return _GuestFormScreenState();
  }
}

class _GuestFormScreenState
    extends ConsumerState<GuestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _documentController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();

  String _documentType = 'cedula';
  bool _isHolder = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namesController.dispose();
    _lastNamesController.dispose();
    _documentController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              isError ? AppColors.error : null,
          content: Text(message),
        ),
      );
  }

  Future<void> _validateGuestQuota({
    required Reserva reservation,
    required List<HuespedReserva> guests,
    required int age,
  }) async {
    if (reservation.estado != ReservaEstado.pendiente) {
      throw const _GuestValidationException(
        'Solo puedes agregar huéspedes a una reserva pendiente.',
      );
    }

    final maximumGuests =
        reservation.cantidadAdultos +
        reservation.cantidadNinos;

    if (guests.length >= maximumGuests) {
      throw _GuestValidationException(
        'La reserva ya tiene completos sus '
        '$maximumGuests cupos.',
      );
    }

    final isChild = age <= 12;

    final registeredChildren = guests.where((guest) {
      final guestAge = guest.edad;

      return guestAge != null && guestAge <= 12;
    }).length;

    final registeredAdults =
        guests.length - registeredChildren;

    if (isChild &&
        registeredChildren >=
            reservation.cantidadNinos) {
      throw _GuestValidationException(
        reservation.cantidadNinos == 0
            ? 'Esta reserva no incluye cupos para niños.'
            : 'Ya se registraron todos los niños '
                'incluidos en la reserva.',
      );
    }

    if (!isChild &&
        registeredAdults >=
            reservation.cantidadAdultos) {
      throw _GuestValidationException(
        'Ya se registraron todos los adultos '
        'incluidos en la reserva.',
      );
    }

    if (_isHolder &&
        guests.any((guest) => guest.esTitular)) {
      throw const _GuestValidationException(
        'La reserva ya tiene un huésped titular.',
      );
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting ||
        !_formKey.currentState!.validate()) {
      return;
    }

    final age = int.parse(
      _ageController.text.trim(),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reservation = await ref.read(
        reservaDetailProvider(
          widget.reservationId,
        ).future,
      );

      final guests = await ref.read(
        huespedesReservaProvider(
          widget.reservationId,
        ).future,
      );

      await _validateGuestQuota(
        reservation: reservation,
        guests: guests,
        age: age,
      );

      final phone = _phoneController.text.trim();

      final request = HuespedReservaRequest(
        reservaId: widget.reservationId,
        nombres: _namesController.text,
        apellidos: _lastNamesController.text,
        tipoDocumento: _documentType,
        numeroDocumento:
            _documentController.text,
        edad: age,
        telefono: phone.isEmpty ? null : phone,
        esTitular: _isHolder,
      );

      await ref
          .read(reservationRepositoryProvider)
          .createHuespedReserva(request);

      ref.invalidate(
        huespedesReservaProvider(
          widget.reservationId,
        ),
      );

      ref.invalidate(
        reservaDetailProvider(
          widget.reservationId,
        ),
      );

      if (!mounted) return;

      _showMessage(
        'Huésped agregado correctamente',
      );

      context.pop(true);
    } on _GuestValidationException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message,
        isError: true,
      );
    } on ApiException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message,
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'No se pudo guardar el huésped.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }

    return null;
  }

  String? _ageValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La edad es obligatoria';
    }

    final age = int.tryParse(value.trim());

    if (age == null || age < 0 || age > 120) {
      return 'Edad inválida';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final reservationAsync = ref.watch(
      reservaDetailProvider(
        widget.reservationId,
      ),
    );

    final guestsAsync = ref.watch(
      huespedesReservaProvider(
        widget.reservationId,
      ),
    );

    final reservation =
        reservationAsync.asData?.value;

    final guests = guestsAsync.asData?.value;

    final maximumGuests = reservation == null
        ? null
        : reservation.cantidadAdultos +
            reservation.cantidadNinos;

    final isFull = maximumGuests != null &&
        guests != null &&
        guests.length >= maximumGuests;

    final isReservationPending =
        reservation?.estado ==
            ReservaEstado.pendiente;

    final canSubmit = !_isSubmitting &&
        !isFull &&
        (reservation == null ||
            isReservationPending);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar huésped'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              32,
            ),
            children: [
              _GuestQuotaCard(
                reservation: reservation,
                guests: guests,
                isLoading:
                    reservationAsync.isLoading ||
                    guestsAsync.isLoading,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ingresa los datos tal como aparecen '
                        'en el documento de identidad. '
                        'De 0 a 12 años se considera niño; '
                        'mayor de 12 años se considera adulto.',
                        style: TextStyle(
                          color:
                              AppColors.textPrimary,
                          height: 1.4,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namesController,
                enabled: canSubmit,
                textCapitalization:
                    TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                  ),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNamesController,
                enabled: canSubmit,
                textCapitalization:
                    TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                  ),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _documentType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de documento',
                  prefixIcon: Icon(
                    Icons.credit_card_outlined,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'cedula',
                    child: Text('Cédula'),
                  ),
                  DropdownMenuItem(
                    value: 'pasaporte',
                    child: Text('Pasaporte'),
                  ),
                  DropdownMenuItem(
                    value: 'otro',
                    child: Text('Otro documento'),
                  ),
                ],
                onChanged: canSubmit
                    ? (value) {
                        if (value == null) return;

                        setState(() {
                          _documentType = value;
                        });
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _documentController,
                enabled: canSubmit,
                decoration: const InputDecoration(
                  labelText: 'Número de documento',
                  prefixIcon: Icon(
                    Icons.numbers_rounded,
                  ),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      enabled: canSubmit,
                      keyboardType:
                          TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly,
                      ],
                      decoration:
                          const InputDecoration(
                        labelText: 'Edad',
                        prefixIcon: Icon(
                          Icons.cake_outlined,
                        ),
                      ),
                      validator: _ageValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      enabled: canSubmit,
                      keyboardType:
                          TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .allow(
                          RegExp(r'[0-9+ -]'),
                        ),
                      ],
                      decoration:
                          const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: SwitchListTile(
                  value: _isHolder,
                  activeThumbColor:
                      AppColors.primary,
                  activeTrackColor:
                      AppColors.primarySoft,
                  title: const Text(
                    'Huésped titular',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Es la persona responsable '
                    'de la reserva.',
                  ),
                  onChanged: canSubmit
                      ? (value) {
                          setState(() {
                            _isHolder = value;
                          });
                        }
                      : null,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed:
                      canSubmit ? _submit : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : Icon(
                          isFull
                              ? Icons
                                  .check_circle_rounded
                              : Icons
                                  .person_add_alt_1_rounded,
                        ),
                  label: Text(
                    _isSubmitting
                        ? 'Guardando...'
                        : isFull
                            ? 'Cupo completo'
                            : 'Agregar huésped',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestQuotaCard extends StatelessWidget {
  const _GuestQuotaCard({
    required this.reservation,
    required this.guests,
    required this.isLoading,
  });

  final Reserva? reservation;
  final List<HuespedReserva>? guests;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading ||
        reservation == null ||
        guests == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Comprobando cupos...',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final registeredChildren =
        guests!.where((guest) {
      final age = guest.edad;

      return age != null && age <= 12;
    }).length;

    final registeredAdults =
        guests!.length - registeredChildren;

    final maximumGuests =
        reservation!.cantidadAdultos +
        reservation!.cantidadNinos;

    final isFull =
        guests!.length >= maximumGuests;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isFull
            ? AppColors.successSoft
            : AppColors.infoSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFull
                    ? Icons.check_circle_rounded
                    : Icons.groups_outlined,
                color: isFull
                    ? AppColors.success
                    : AppColors.info,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isFull
                      ? 'Cupo completo'
                      : 'Cupos de la reserva',
                  style: TextStyle(
                    color: isFull
                        ? AppColors.success
                        : AppColors.info,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${guests!.length}/$maximumGuests',
                style: TextStyle(
                  color: isFull
                      ? AppColors.success
                      : AppColors.info,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _QuotaRow(
            label: 'Adultos',
            registered: registeredAdults,
            maximum:
                reservation!.cantidadAdultos,
          ),
          const SizedBox(height: 8),
          _QuotaRow(
            label: 'Niños',
            registered: registeredChildren,
            maximum:
                reservation!.cantidadNinos,
          ),
        ],
      ),
    );
  }
}

class _QuotaRow extends StatelessWidget {
  const _QuotaRow({
    required this.label,
    required this.registered,
    required this.maximum,
  });

  final String label;
  final int registered;
  final int maximum;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '$registered de $maximum',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _GuestValidationException implements Exception {
  const _GuestValidationException(this.message);

  final String message;
}