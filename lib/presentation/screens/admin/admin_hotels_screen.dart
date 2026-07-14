import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/model/hotel.dart';
import '../../../theme/app_colors.dart';
import '../../providers/admin_provider.dart';

class AdminHotelsScreen extends ConsumerStatefulWidget {
  const AdminHotelsScreen({super.key});

  @override
  ConsumerState<AdminHotelsScreen> createState() => _AdminHotelsScreenState();
}

class _AdminHotelsScreenState extends ConsumerState<AdminHotelsScreen> {
  Future<void> _refresh() async {
    ref.invalidate(adminHotelsProvider);
    await ref.read(adminHotelsProvider.future);
  }

  Future<void> _openForm({Hotel? hotel}) async {
    final result = await showDialog<_HotelFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _HotelFormDialog(hotel: hotel),
    );

    if (result == null || !mounted) {
      return;
    }

    final controller = ref.read(adminControllerProvider.notifier);

    final success = hotel == null
        ? await controller.createHotel(
            result.data,
            logo: result.logo!,
          )
        : await controller.updateHotel(
            hotel.id,
            result.data,
            logo: result.logo,
          );

    if (!mounted) {
      return;
    }

    _showMessage(
      success
          ? hotel == null
              ? 'Hotel creado correctamente.'
              : 'Hotel actualizado correctamente.'
          : 'No se pudo guardar el hotel.',
      isError: !success,
    );
  }

  Future<void> _deleteHotel(Hotel hotel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar hotel'),
          content: Text(
            'Deseas eliminar "${hotel.nombre}"?\n\n'
            'No podras eliminarlo si contiene habitaciones o reservas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final success =
        await ref.read(adminControllerProvider.notifier).deleteHotel(hotel.id);

    if (!mounted) {
      return;
    }

    _showMessage(
      success
          ? 'Hotel eliminado correctamente.'
          : 'No se pudo eliminar el hotel.',
      isError: !success,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final hotelsAsync = ref.watch(adminHotelsProvider);
    final isSaving = ref.watch(adminControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administrar hoteles'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: isSaving ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: isSaving ? null : () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo hotel'),
      ),
      body: hotelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: _refresh,
        ),
        data: (hotels) {
          if (hotels.isEmpty) {
            return _EmptyState(onCreate: () => _openForm());
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: hotels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final hotel = hotels[index];

                return Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _HotelLogo(hotel: hotel),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotel.nombre,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${hotel.categoriaEstrellas} estrellas Ã‚Â· ${hotel.estado}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hotel.email,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _openForm(hotel: hotel);
                              case 'delete':
                                _deleteHotel(hotel);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Editar'),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.delete_outline),
                                title: Text('Eliminar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HotelLogo extends StatelessWidget {
  const _HotelLogo({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final url = hotel.logoUrl?.trim() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 72,
        height: 72,
        child: url.isEmpty
            ? const ColoredBox(
                color: AppColors.primarySoft,
                child: Icon(
                  Icons.hotel_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: AppColors.primarySoft,
                    child: Icon(
                      Icons.hotel_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _HotelFormResult {
  const _HotelFormResult({
    required this.data,
    required this.logo,
  });

  final Map<String, dynamic> data;
  final XFile? logo;
}

class _HotelFormDialog extends StatefulWidget {
  const _HotelFormDialog({this.hotel});

  final Hotel? hotel;

  @override
  State<_HotelFormDialog> createState() => _HotelFormDialogState();
}

class _HotelFormDialogState extends State<_HotelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _name;
  late final TextEditingController _ruc;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _description;
  late final TextEditingController _checkIn;
  late final TextEditingController _checkOut;
  late final TextEditingController _minimumAge;
  late final TextEditingController _policy;

  XFile? _logo;
  Uint8List? _logoBytes;
  int _stars = 3;
  String _status = 'ACTIVO';
  bool _pets = false;

  bool get _isEditing => widget.hotel != null;

  @override
  void initState() {
    super.initState();

    final hotel = widget.hotel;
    _name = TextEditingController(text: hotel?.nombre ?? '');
    _ruc = TextEditingController(text: hotel?.ruc ?? '');
    _phone = TextEditingController(text: hotel?.telefono ?? '');
    _email = TextEditingController(text: hotel?.email ?? '');
    _description = TextEditingController(text: hotel?.descripcion ?? '');
    _checkIn = TextEditingController(text: hotel?.horaCheckIn ?? '14:00');
    _checkOut = TextEditingController(text: hotel?.horaCheckOut ?? '12:00');
    _minimumAge = TextEditingController(
      text: (hotel?.edadMinimaReserva ?? 18).toString(),
    );
    _policy = TextEditingController(
      text:
          hotel?.politicaCancelacion ?? 'Cancelacion sujeta a disponibilidad.',
    );

    _stars = hotel?.categoriaEstrellas ?? 3;
    _status = hotel?.estado.trim().toUpperCase() ?? 'ACTIVO';
    _pets = hotel?.permiteMascotas ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _ruc.dispose();
    _phone.dispose();
    _email.dispose();
    _description.dispose();
    _checkIn.dispose();
    _checkOut.dispose();
    _minimumAge.dispose();
    _policy.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      _logo = image;
      _logoBytes = bytes;
    });
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio.';
    }

    return null;
  }

  String _timeForApi(String value) {
    final clean = value.trim();

    if (clean.length == 5) {
      return '$clean:00';
    }

    return clean;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_isEditing && _logo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una imagen para el hotel.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _HotelFormResult(
        logo: _logo,
        data: {
          'nombre': _name.text.trim(),
          'ruc': _ruc.text.trim(),
          'telefono': _phone.text.trim(),
          'email': _email.text.trim(),
          'descripcion': _description.text.trim(),
          'categoria_estrellas': _stars,
          'estado': _status,
          'hora_check_in': _timeForApi(_checkIn.text),
          'hora_check_out': _timeForApi(_checkOut.text),
          'permite_mascotas': _pets,
          'edad_minima_reserva': int.parse(_minimumAge.text.trim()),
          'politica_cancelacion': _policy.text.trim(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar hotel' : 'Nuevo hotel'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _pickLogo,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 165,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                    ),
                    child: _logoBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(19),
                            child: Image.memory(
                              _logoBytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 44,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isEditing
                                    ? 'Cambiar imagen del hotel'
                                    : 'Toca para cargar imagen del hotel',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                _Field(
                    controller: _name,
                    label: 'Nombre del hotel',
                    validator: _required),
                _Field(controller: _ruc, label: 'RUC', validator: _required),
                _Field(
                  controller: _phone,
                  label: 'Telefono',
                  keyboardType: TextInputType.phone,
                  validator: _required,
                ),
                _Field(
                  controller: _email,
                  label: 'Correo electronico',
                  keyboardType: TextInputType.emailAddress,
                  validator: _required,
                ),
                _Field(
                  controller: _description,
                  label: 'Descripcion',
                  maxLines: 3,
                  validator: _required,
                ),
                DropdownButtonFormField<int>(
                  initialValue: _stars,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: List.generate(
                    5,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1} estrellas'),
                    ),
                  ),
                  onChanged: (value) => setState(() => _stars = value ?? 3),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: const {'ACTIVO', 'INACTIVO'}.contains(_status)
                      ? _status
                      : 'ACTIVO',
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVO', child: Text('Activo')),
                    DropdownMenuItem(
                        value: 'INACTIVO', child: Text('Inactivo')),
                  ],
                  onChanged: (value) =>
                      setState(() => _status = value ?? 'ACTIVO'),
                ),
                _Field(
                  controller: _checkIn,
                  label: 'Hora de entrada (HH:mm)',
                  validator: _required,
                ),
                _Field(
                  controller: _checkOut,
                  label: 'Hora de salida (HH:mm)',
                  validator: _required,
                ),
                _Field(
                  controller: _minimumAge,
                  label: 'Edad minima para reservar',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    return parsed == null || parsed < 0
                        ? 'Ingresa una edad valida.'
                        : null;
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Permite mascotas'),
                  value: _pets,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => setState(() => _pets = value),
                ),
                _Field(
                  controller: _policy,
                  label: 'Politica de cancelacion',
                  maxLines: 3,
                  validator: _required,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(_isEditing ? 'Guardar cambios' : 'Crear hotel'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hotel_outlined,
              size: 70,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Todavia no hay hoteles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea el primer hotel y carga su imagen.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear hotel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 60,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar los hoteles',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
