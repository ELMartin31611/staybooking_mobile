import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/model/huesped_reserva.dart';
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

class _GuestFormScreenState extends ConsumerState<GuestFormScreen> {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = HuespedReservaRequest(
        reservaId: widget.reservationId,
        nombres: _namesController.text,
        apellidos: _lastNamesController.text,
        tipoDocumento: _documentType,
        numeroDocumento: _documentController.text,
        edad: int.tryParse(
          _ageController.text.trim(),
        ),
        telefono:
            _phoneController.text.trim().isEmpty ? null : _phoneController.text,
        esTitular: _isHolder,
      );

      await ref
          .read(reservationRepositoryProvider)
          .createHuespedReserva(request);

      ref.invalidate(
        huespedesReservaProvider(widget.reservationId),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Huésped agregado correctamente',
          ),
        ),
      );

      context.pop(true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar el huésped',
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ingresa los datos tal como aparecen en el documento de identidad.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namesController,
                textCapitalization: TextCapitalization.words,
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
                textCapitalization: TextCapitalization.words,
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
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _documentType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _documentController,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Edad',
                        prefixIcon: Icon(
                          Icons.cake_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }

                        final age = int.tryParse(value);

                        if (age == null || age < 0 || age > 120) {
                          return 'Edad inválida';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+ -]'),
                        ),
                      ],
                      decoration: const InputDecoration(
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
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: SwitchListTile(
                  value: _isHolder,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primarySoft,
                  title: const Text(
                    'Huésped titular',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Es la persona responsable de la reserva.',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isHolder = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
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
                        Icons.person_add_alt_1_rounded,
                      ),
                label: Text(
                  _isSubmitting ? 'Guardando...' : 'Agregar huésped',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
