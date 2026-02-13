import 'package:flutter/material.dart';
import 'package:proyecto2ev/models/event.dart';
import 'package:provider/provider.dart';
import 'package:proyecto2ev/provider/events_service.dart';
import 'package:proyecto2ev/provider/selected_event_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';


class EventAdd extends StatefulWidget {
  const EventAdd({super.key});

  @override
  State<EventAdd> createState() => _EventAddState();
}

class _EventAddState extends State<EventAdd> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: "0");
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  File? _image;
  bool _hasChanges = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsService = context.read<EventsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo evento"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await changesConfirmation(context) == true) {
              Navigator.of(context).pop();
            }
          }
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: () => _hasChanges = true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.title),
                  labelText: 'Título',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduzca un título';
                  }
                  if (value.length < 5 || value.length > 50) {
                    return 'El título debe tener entre 5 y 50 caracteres';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.description),
                  labelText: 'Descripción',
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
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: 'Fecha',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La fecha es obligatoria';
                  }
                  if ( DateTime.parse(value).isBefore(
                       DateTime.now().subtract(const Duration(days: 1)))) {
                    return 'La fecha debe ser hoy o posterior';
                  }
                  return null;
                },
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
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
                controller: _priceController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.attach_money),
                  labelText: 'Precio',
                ),
                keyboardType: TextInputType.number,
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
                controller: _imageController,
                readOnly: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.image),
                  labelText: 'Imagen',
                ),
                onTap: pickImage,
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(
                    _image!,
                    height: 150,
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Evento añadido')),
                      );
                      eventsService
                          .createEvent(Event(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            price: double.tryParse(_priceController.text)!,
                            date: _dateController.text.isNotEmpty
                                ? DateTime.parse(_dateController.text)
                                : DateTime.now(),
                            image: _imageController.text,
                          ))
                          .then((value) => {
                                if (value != null)
                                  {Navigator.pop(context, value)}
                                else
                                  {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Revise los datos')),
                                    )
                                  }
                              });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Revise los datos')),
                      );
                    }
                  },
                  child: const Text('Crear'),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Descartar cambios'),
                        content: const Text('Hay cambios sin guardar. ¿Desea descartarlos?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }
                          ),
                          TextButton(
                            child: const Text('Descartar'),
                            onPressed: () {
                              // Cerramos el diálogo y volvemos a la página anterior sin guardar los cambios
                              Navigator.of(context).pop(); 
                              Navigator.of(context).pop(); 
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Descartar'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /* Diálogo de confirmación para cambios sin guardar */
  Future<bool?> changesConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambios sin guardar'),
          content: const Text('Hay cambios sin guardar. ¿Desea salir sin guardar?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false); 
              }
            ),
            TextButton(
              child: const Text('Descartar'),
              onPressed: () {
                Navigator.of(context).pop(true); 
              }
            ),
          ],
        );
      },
    );
  }


  /* Seleccionar imagen */
  Future<void> pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _image = File(pickedImage.path);
          _imageController.text = pickedImage.path;
        });
      }
    } catch (e) {
      debugPrint("Error seleccionando imagen: $e");
    }
  }
}
