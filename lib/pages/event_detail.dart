import 'package:flutter/material.dart';
import 'package:proyecto2ev/models/event.dart';
import 'package:provider/provider.dart';
import 'package:proyecto2ev/provider/events_service.dart';
import 'package:proyecto2ev/provider/selected_event_notifier.dart';
import 'package:proyecto2ev/pages/event_edit.dart';

class EventDetail extends StatefulWidget {
  const EventDetail(
      {super.key, required this.event, required this.closeCallback}
  );

  final Function closeCallback;
  final Event? event;

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  Event? event;
  
  @override
  Widget build(BuildContext context) {
    event = context.watch<SelectedEventNotifier>().selectedEvent;

    return ChangeNotifierProvider.value(
      value: context.read<SelectedEventNotifier>(),
      child: Consumer<SelectedEventNotifier>(
        builder: (context, service, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text( (event == null) ? '' : event!.title),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.read<SelectedEventNotifier>().clear();
                  widget.closeCallback();
                },
              ),
              actions: [
                /* Editar evento */
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar Evento',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          EventEdit(event: event!)
                      ),
                    ).then((value) => {
                      context
                        .read<SelectedEventNotifier>()
                        .selectedEvent = value,
                    });
                  },
                ),
                /* Eliminar evento */
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Eliminar Evento',
                  onPressed: () {
                    if (event != null && event!.id != null) {
                      deleteConfirm(
                          context,
                          event!,
                          context.read<EventsService>(),
                          widget.closeCallback
                      );
                    }
                  },
                )
              ],
            ),
            body: Container(
              padding: const EdgeInsets.all(16.0),
              child: (event == null) ? const Center(child: CircularProgressIndicator()) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event!.title,
                    style:  const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    event!.description,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Fecha: ${event!.date.toLocal()}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Precio: \$${event!.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  //ImageLoader(event: event!, size: 300),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /* Diálogo de confirmación para el borrado*/
  Future<dynamic> deleteConfirm(
    BuildContext context, 
    Event event,
    EventsService service, 
    Function deleteCallback) 
  {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: Text('¿Está seguro de eliminar, "${event.title}"?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                service.deleteEvent(event).then((value) => {
                  service.loadEvents(),
                  Navigator.of(context).pop(),
                  deleteCallback(),
                });
              },
            ),
          ],
        );
      },
    );
  }
}
