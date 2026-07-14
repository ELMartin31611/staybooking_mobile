import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/model/habitacion.dart';
import '../../../domain/model/hotel.dart';
import '../../../domain/model/tipo_habitacion.dart';
import '../../../theme/app_colors.dart';
import '../../providers/admin_provider.dart';

class AdminRoomsScreen extends ConsumerStatefulWidget {
  const AdminRoomsScreen({super.key});

  @override
  ConsumerState<AdminRoomsScreen> createState() => _AdminRoomsScreenState();
}

class _AdminRoomsScreenState extends ConsumerState<AdminRoomsScreen> {
  Future<void> _refresh() async {
    ref.invalidate(adminRoomsProvider);
    ref.invalidate(adminHotelsProvider);
    ref.invalidate(adminRoomTypesProvider);

    await Future.wait([
      ref.read(adminRoomsProvider.future),
      ref.read(adminHotelsProvider.future),
      ref.read(adminRoomTypesProvider.future),
    ]);
  }

  Future<void> _openRoomForm({Habitacion? room}) async {
    final hotels = await ref.read(adminHotelsProvider.future);
    final roomTypes = await ref.read(adminRoomTypesProvider.future);

    if (!mounted) {
      return;
    }

    if (hotels.isEmpty) {
      _showMessage(
        'Primero crea un hotel.',
        isError: true,
      );
      return;
    }

    final result = await showDialog<_RoomFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _RoomFormDialog(
          room: room,
          hotels: hotels,
          roomTypes: roomTypes,
          onCreateType: (hotelId) {
            return _openRoomTypeForm(
              initialHotelId: hotelId,
              showSuccessMessage: false,
            );
          },
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    final controller = ref.read(adminControllerProvider.notifier);

    final success = room == null
        ? await controller.createRoom(
            result.data,
            image: result.image!,
          )
        : await controller.updateRoom(
            room.id,
            result.data,
          );

    if (!mounted) {
      return;
    }

    _showMessage(
      success
          ? room == null
              ? 'Habitacion creada con su imagen principal.'
              : 'Habitacion actualizada correctamente.'
          : 'No se pudo guardar la habitacion.',
      isError: !success,
    );
  }

  Future<List<TipoHabitacion>> _openRoomTypeForm({
    int? initialHotelId,
    bool showSuccessMessage = true,
  }) async {
    final hotels = await ref.read(adminHotelsProvider.future);

    if (!mounted) {
      return <TipoHabitacion>[];
    }

    if (hotels.isEmpty) {
      _showMessage(
        'Primero crea un hotel.',
        isError: true,
      );
      return <TipoHabitacion>[];
    }

    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RoomTypeFormDialog(
        hotels: hotels,
        initialHotelId: initialHotelId,
      ),
    );

    if (data == null || !mounted) {
      return ref.read(adminRoomTypesProvider.future);
    }

    final success =
        await ref.read(adminControllerProvider.notifier).createRoomType(data);

    if (!mounted) {
      return <TipoHabitacion>[];
    }

    if (!success) {
      _showMessage(
        'No se pudo crear el tipo de habitacion.',
        isError: true,
      );
      return ref.read(adminRoomTypesProvider.future);
    }

    ref.invalidate(adminRoomTypesProvider);
    final updatedTypes = await ref.read(adminRoomTypesProvider.future);

    if (showSuccessMessage && mounted) {
      _showMessage(
        'Tipo de habitacion creado correctamente.',
      );
    }

    return updatedTypes;
  }

  Future<void> _deleteRoom(Habitacion room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar habitacion'),
          content: Text(
            'Deseas eliminar la habitacion ${room.numero}?\n\n'
            'No se podra eliminar si tiene reservas relacionadas.',
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
        await ref.read(adminControllerProvider.notifier).deleteRoom(room.id);

    if (!mounted) {
      return;
    }

    _showMessage(
      success ? 'Habitacion eliminada.' : 'No se pudo eliminar la habitacion.',
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

  String _hotelName(int? hotelId, List<Hotel> hotels) {
    return hotels
            .where((hotel) => hotel.id == hotelId)
            .map((hotel) => hotel.nombre)
            .firstOrNull ??
        'Hotel no identificado';
  }

  String _typeName(int? typeId, List<TipoHabitacion> types) {
    return types
            .where((type) => type.id == typeId)
            .map((type) => type.nombre)
            .firstOrNull ??
        'Tipo no identificado';
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(adminRoomsProvider);
    final hotels = ref.watch(adminHotelsProvider).valueOrNull ?? <Hotel>[];
    final types =
        ref.watch(adminRoomTypesProvider).valueOrNull ?? <TipoHabitacion>[];
    final isSaving = ref.watch(adminControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Administrar habitaciones'),
        actions: [
          IconButton(
            tooltip: 'Crear tipo de habitacion',
            onPressed: isSaving
                ? null
                : () {
                    _openRoomTypeForm();
                  },
            icon: const Icon(Icons.category_outlined),
          ),
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
        onPressed: isSaving ? null : () => _openRoomForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva habitacion'),
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _RoomsError(
          message: error.toString(),
          onRetry: _refresh,
        ),
        data: (rooms) {
          if (rooms.isEmpty) {
            return _RoomsEmpty(
              onCreateType: () {
                _openRoomTypeForm();
              },
              onCreateRoom: _openRoomForm,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: rooms.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final room = rooms[index];

                return _RoomCard(
                  room: room,
                  hotelName: _hotelName(room.hotelId, hotels),
                  typeName: _typeName(room.tipoHabitacionId, types),
                  onEdit: () => _openRoomForm(room: room),
                  onImages: () {
                    context.push('/habitaciones/${room.id}/imagenes');
                  },
                  onDelete: () => _deleteRoom(room),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RoomFormResult {
  const _RoomFormResult({
    required this.data,
    required this.image,
  });

  final Map<String, dynamic> data;
  final XFile? image;
}

class _RoomFormDialog extends StatefulWidget {
  const _RoomFormDialog({
    required this.room,
    required this.hotels,
    required this.roomTypes,
    required this.onCreateType,
  });

  final Habitacion? room;
  final List<Hotel> hotels;
  final List<TipoHabitacion> roomTypes;
  final Future<List<TipoHabitacion>> Function(int hotelId) onCreateType;

  @override
  State<_RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<_RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _number;
  late final TextEditingController _floor;
  late final TextEditingController _description;
  late final TextEditingController _observations;

  int? _hotelId;
  int? _typeId;
  String _status = 'DISPONIBLE';
  bool _smoking = false;
  XFile? _image;
  Uint8List? _imageBytes;
  late List<TipoHabitacion> _roomTypes;
  bool _creatingType = false;

  bool get _isEditing => widget.room != null;

  List<TipoHabitacion> get _availableTypes {
    return _roomTypes.where((type) => type.hotelId == _hotelId).toList();
  }

  @override
  void initState() {
    super.initState();

    final room = widget.room;
    _roomTypes = List<TipoHabitacion>.from(widget.roomTypes);
    _number = TextEditingController(text: room?.numero ?? '');
    _floor = TextEditingController(text: (room?.piso ?? 1).toString());
    _description = TextEditingController(text: room?.descripcion ?? '');
    _observations = TextEditingController(
      text: room?.raw['observaciones']?.toString() ?? '',
    );

    _hotelId = room?.hotelId ?? widget.hotels.first.id;

    final available = _availableTypes;
    _typeId = available.any((type) => type.id == room?.tipoHabitacionId)
        ? room?.tipoHabitacionId
        : available.isEmpty
            ? null
            : available.first.id;

    const validStates = {
      'DISPONIBLE',
      'OCUPADA',
      'MANTENIMIENTO',
      'INACTIVA',
    };

    final initial = room?.estado.trim().toUpperCase() ?? 'DISPONIBLE';
    _status = validStates.contains(initial) ? initial : 'DISPONIBLE';
    _smoking = room?.raw['es_fumador'] == true;
  }

  @override
  void dispose() {
    _number.dispose();
    _floor.dispose();
    _description.dispose();
    _observations.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
      _image = image;
      _imageBytes = bytes;
    });
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Campo obligatorio.' : null;
  }

  void _changeHotel(int? hotelId) {
    setState(() {
      _hotelId = hotelId;
      final types = _availableTypes;
      _typeId = types.isEmpty ? null : types.first.id;
    });
  }

  Future<void> _createTypeForSelectedHotel() async {
    final hotelId = _hotelId;

    if (hotelId == null || _creatingType) {
      return;
    }

    setState(() {
      _creatingType = true;
    });

    try {
      final updatedTypes = await widget.onCreateType(hotelId);

      if (!mounted) {
        return;
      }

      setState(() {
        _roomTypes = updatedTypes;

        final typesForHotel = _availableTypes;

        if (typesForHotel.isNotEmpty) {
          _typeId = typesForHotel.last.id;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _creatingType = false;
        });
      }
    }
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_hotelId == null || _typeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona hotel y tipo de habitacion.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_isEditing && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la imagen principal de la habitacion.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _RoomFormResult(
        image: _image,
        data: {
          'hotel': _hotelId,
          'tipo_habitacion': _typeId,
          'numero': _number.text.trim(),
          'piso': int.parse(_floor.text.trim()),
          'estado': _status,
          'descripcion': _description.text.trim(),
          'es_fumador': _smoking,
          'observaciones': _observations.text.trim(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final types = _availableTypes;

    return AlertDialog(
      title: Text(_isEditing ? 'Editar habitacion' : 'Nueva habitacion'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: _imageBytes == null
                        ? Column(
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
                                    ? 'Cambiar imagen principal'
                                    : 'Cargar imagen principal',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(19),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<int>(
                  initialValue: _hotelId,
                  decoration: const InputDecoration(labelText: 'Hotel'),
                  items: widget.hotels
                      .map(
                        (hotel) => DropdownMenuItem(
                          value: hotel.id,
                          child: Text(hotel.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: _changeHotel,
                ),
                const SizedBox(height: 14),
                if (types.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warningSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          color: AppColors.warning,
                          size: 34,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Este hotel aun no tiene tipos de habitacion.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _creatingType
                              ? null
                              : _createTypeForSelectedHotel,
                          icon: _creatingType
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add_rounded),
                          label: Text(
                            _creatingType
                                ? 'Creando tipo...'
                                : 'Crear tipo para este hotel',
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  DropdownButtonFormField<int>(
                    key: ValueKey('room_type_${_hotelId}_${_typeId}'),
                    initialValue: _typeId,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de habitacion',
                    ),
                    items: types
                        .map(
                          (type) => DropdownMenuItem(
                            value: type.id,
                            child: Text(
                              '${type.nombre} - ${type.capacidadTotal} huespedes',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _typeId = value),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed:
                          _creatingType ? null : _createTypeForSelectedHotel,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Crear otro tipo'),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _FormField(
                  controller: _number,
                  label: 'Numero de habitacion',
                  validator: _required,
                ),
                _FormField(
                  controller: _floor,
                  label: 'Piso',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final floor = int.tryParse(value?.trim() ?? '');
                    return floor == null || floor < 0
                        ? 'Ingresa un piso valido.'
                        : null;
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(
                      value: 'DISPONIBLE',
                      child: Text('Disponible'),
                    ),
                    DropdownMenuItem(
                      value: 'OCUPADA',
                      child: Text('Ocupada'),
                    ),
                    DropdownMenuItem(
                      value: 'MANTENIMIENTO',
                      child: Text('Mantenimiento'),
                    ),
                    DropdownMenuItem(
                      value: 'INACTIVA',
                      child: Text('Inactiva'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _status = value ?? 'DISPONIBLE');
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Permite fumar'),
                  value: _smoking,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => setState(() => _smoking = value),
                ),
                _FormField(
                  controller: _description,
                  label: 'Descripcion',
                  maxLines: 3,
                  validator: _required,
                ),
                _FormField(
                  controller: _observations,
                  label: 'Observaciones',
                  maxLines: 2,
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
          child: Text(_isEditing ? 'Guardar cambios' : 'Crear habitacion'),
        ),
      ],
    );
  }
}

class _RoomTypeFormDialog extends StatefulWidget {
  const _RoomTypeFormDialog({
    required this.hotels,
    this.initialHotelId,
  });

  final List<Hotel> hotels;
  final int? initialHotelId;

  @override
  State<_RoomTypeFormDialog> createState() => _RoomTypeFormDialogState();
}

class _RoomTypeFormDialogState extends State<_RoomTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _adults;
  late final TextEditingController _children;
  late final TextEditingController _size;
  late final TextEditingController _price;

  late int _hotelId;
  String _status = 'ACTIVO';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _description = TextEditingController();
    _adults = TextEditingController(text: '2');
    _children = TextEditingController(text: '0');
    _size = TextEditingController(text: '25');
    _price = TextEditingController(text: '30');
    final requestedHotelId = widget.initialHotelId;

    _hotelId = widget.hotels.any((hotel) => hotel.id == requestedHotelId)
        ? requestedHotelId!
        : widget.hotels.first.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _adults.dispose();
    _children.dispose();
    _size.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final adults = int.parse(_adults.text.trim());
    final children = int.parse(_children.text.trim());

    Navigator.pop(
      context,
      {
        'hotel': _hotelId,
        'nombre': _name.text.trim(),
        'descripcion': _description.text.trim(),
        'capacidad_adultos': adults,
        'capacidad_ninos': children,
        'capacidad_total': adults + children,
        'tamano_m2': double.parse(_size.text.trim()),
        'precio_base': double.parse(_price.text.trim()),
        'estado': _status,
      },
    );
  }

  String? _positiveNumber(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || number < 0 ? 'Ingresa un valor valido.' : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo tipo de habitacion'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _hotelId,
                  decoration: const InputDecoration(labelText: 'Hotel'),
                  items: widget.hotels
                      .map(
                        (hotel) => DropdownMenuItem(
                          value: hotel.id,
                          child: Text(hotel.nombre),
                        ),
                      )
                      .toList(),
                  onChanged: widget.initialHotelId != null
                      ? null
                      : (value) => setState(
                            () => _hotelId = value ?? widget.hotels.first.id,
                          ),
                ),
                const SizedBox(height: 14),
                _FormField(
                  controller: _name,
                  label: 'Nombre del tipo',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Campo obligatorio.'
                      : null,
                ),
                _FormField(
                  controller: _description,
                  label: 'Descripcion',
                  maxLines: 3,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Campo obligatorio.'
                      : null,
                ),
                _FormField(
                  controller: _adults,
                  label: 'Capacidad de adultos',
                  keyboardType: TextInputType.number,
                  validator: _positiveNumber,
                ),
                _FormField(
                  controller: _children,
                  label: 'Capacidad de ninos',
                  keyboardType: TextInputType.number,
                  validator: _positiveNumber,
                ),
                _FormField(
                  controller: _size,
                  label: 'Tamano en m2',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _positiveNumber,
                ),
                _FormField(
                  controller: _price,
                  label: 'Precio base por noche',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _positiveNumber,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVO', child: Text('Activo')),
                    DropdownMenuItem(
                        value: 'INACTIVO', child: Text('Inactivo')),
                  ],
                  onChanged: (value) {
                    setState(() => _status = value ?? 'ACTIVO');
                  },
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
          child: const Text('Crear tipo'),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
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

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.hotelName,
    required this.typeName,
    required this.onEdit,
    required this.onImages,
    required this.onDelete,
  });

  final Habitacion room;
  final String hotelName;
  final String typeName;
  final VoidCallback onEdit;
  final VoidCallback onImages;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final available =
        room.disponible || room.estado.trim().toUpperCase() == 'DISPONIBLE';

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor:
              available ? AppColors.successSoft : AppColors.warningSoft,
          child: Icon(
            Icons.bed_rounded,
            color: available ? AppColors.success : AppColors.warning,
          ),
        ),
        title: Text(
          'Habitacion ${room.numero}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '$hotelName\n$typeName - Piso ${room.piso}\n${room.estado}',
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
              case 'images':
                onImages();
              case 'delete':
                onDelete();
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
              value: 'images',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.photo_library_outlined),
                title: Text('Imagenes'),
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
      ),
    );
  }
}

class _RoomsEmpty extends StatelessWidget {
  const _RoomsEmpty({
    required this.onCreateType,
    required this.onCreateRoom,
  });

  final VoidCallback onCreateType;
  final VoidCallback onCreateRoom;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bedroom_parent_outlined,
              size: 72,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Todavia no hay habitaciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Primero crea un tipo de habitacion y despues registra sus habitaciones.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onCreateType,
              icon: const Icon(Icons.category_outlined),
              label: const Text('Crear tipo de habitacion'),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onCreateRoom,
              icon: const Icon(Icons.add),
              label: const Text('Crear habitacion'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomsError extends StatelessWidget {
  const _RoomsError({
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
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar las habitaciones',
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

extension _IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;

    if (!iterator.moveNext()) {
      return null;
    }

    return iterator.current;
  }
}
