import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proyecto2ev/models/event.dart';
import 'package:provider/provider.dart';
import 'package:proyecto2ev/provider/events_service.dart';
import 'package:proyecto2ev/provider/selected_event_notifier.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class EventEdit extends StatefulWidget {
  final Event event;
  const EventEdit({super.key, required this.event});

  @override
  State<EventEdit> createState() => _EventEditState();
}

class _EventEditState extends State<EventEdit> {
  final EventsService eventsNotifier = EventsService();
  bool _hasChanges = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  late Event event;

  @override
  void initState() {
    super.initState();
    event = widget.event;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _priceController.text = event.price.toString();
    _dateController.text = DateFormat('yyyy-MM-dd').format(event.date);;
    _imageController.text = event.image;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _imageController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    File? image;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: backButton,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.title),
                  labelText: "Título",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Introduzca un título";
                  }
                  if (value.length < 5 || value.length > 50) {
                    return 'El título debe tener entre 5 y 50 caracteres';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  icon: Icon(Icons.description),
                  labelText: "Descripción",
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      (value.length < 5 || value.length > 255)) {
                      return 'La descripción debe de tener entre 5 y 255 caracteres';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  icon: Icon(Icons.attach_money),
                  labelText: "Precio",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduzca un precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Introduzca un valor numérico';
                  }
                  if (double.tryParse(value)! < 0) {
                    return 'Introduzca un valor numérico';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: "Fecha",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Introduzca una fecha";
                  }
                  if ( DateTime.parse(value).isBefore(
                       DateTime.now().subtract(const Duration(days: 1)))) {
                    return "La fecha debe ser hoy o posterior";
                  }
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: event.date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
               TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.image_outlined),
                  labelText: 'Image URL',
                ),
                keyboardType: TextInputType.url,
                readOnly: true,
                onTap: () async {
                  XFile? pickedImage = await pickImage();
                  if (pickedImage != null) {
                    image = File(pickedImage.path);
                    setState(() {
                      _imageController.text = image!.path;
                    });
                  }
                },
              ),
              if (_imageController.text.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  "Eliminar imagen",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  setState(() {
                    _imageController.clear();
                  });
                },
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Evento modificado')),
                      );
                      eventsNotifier
                          .modifyEvent(Event(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              price: double.tryParse(_priceController.text)!,
                              date: _dateController.text.isNotEmpty
                                  ? DateTime.parse(_dateController.text)
                                  : DateTime.now(),
                              image: _imageController.text,))
                          .then((value) => {
                                context
                                    .read<SelectedEventNotifier>()
                                    .selectedEvent = value!,
                                context
                                    .read<EventsService>()
                                    .loadEvents(),
                                Navigator.pop(context, value)
                          });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Revise los datos')),
                      );
                    }
                  },
                  child: const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* Coger la imagen correspondiente */
  Future pickImage() async {
    final XFile? image;
    try {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
      return image;
    } on PlatformException catch (e) {
      debugPrint('Error seleccionando imagen: $e');
    }
  }

  /* Botón para volver a la página anterior */
  void backButton() {
    if (!_hasChanges) {
      Navigator.pop(context);
    } else {
      changesDialog();
    }
  }

  /* Diálogo de confirmación de los cambios */
  void changesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambios sin guardar'),
          content: const Text('¿Desea salir sin guardar los cambios?'),
          actions: [
            TextButton(
              child: const Text("Guardar"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  saveChanges();
                  Navigator.pop(context);
                }
              },
            ),
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text("Descartar"),
              onPressed: () {
                // Cerramos el diálogo y volvemos a la página anterior sin guardar los cambios
                  Navigator.pop(context);
                  Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void saveChanges() {
    // Creamos un nuevo evento con los datos modificados
    final updatedEvent = Event(
      title: _titleController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      date: DateTime.parse(_dateController.text),
      image: _imageController.text,
      isFavorite: event.isFavorite,
    );

    _hasChanges = false;

    // Actualizamos el evento en el servicio y en el notifier
    eventsNotifier.modifyEvent(updatedEvent);
    context.read<SelectedEventNotifier>().selectedEvent = updatedEvent;

    // Volvemos a la página anterior pasando el evento modificado
    Navigator.pop(context, updatedEvent);
  }
}