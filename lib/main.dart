import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proyecto2ev/models/event.dart';
import 'package:proyecto2ev/provider/events_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => EventsService(),
      child: const MainApp()
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listado de eventos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Events(),
    );
  }
}

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  List<Event> events = [];

  /* Variables de filtrado */ 
  bool showOnlyFavorites = false;
  bool showPastEvents = false;
  bool sortByDate = false;
  bool sortByPrice = false;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<EventsService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de eventos'),
        actions: [
          /* Crear nuevo evento */ 
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Crear evento',
            onPressed: () {
              /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateEvent(),
                ),
              );*/
            },
          ),
        ],
        /* Elementos de filtrado */
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /* Filtrar por favoritos */
                    FilterChip(
                      label: const Text('Solo favoritos'),
                      selected: showOnlyFavorites,
                      onSelected: (value) {
                        setState(() {
                          showOnlyFavorites = value;
                        });
                      },
                    ),
                    /* Filtrar por fecha */
                    ChoiceChip(
                      label: const Text('Fecha'),
                      selected: sortByDate,
                      onSelected: (value) {
                        setState(() {
                          sortByDate = value;
                        });
                      },
                    ),
                    /* Filtrar por precio */
                    ChoiceChip(
                      label: const Text('Precio'),
                      selected: sortByPrice,
                      onSelected: (value) {
                        setState(() {
                          sortByPrice = value;
                        });
                      },
                    ),
                    /* Filtrar por eventos pasados */
                    FilterChip(
                      label: const Text('Eventos pasados'),
                      selected: showPastEvents,
                      onSelected: (value) {
                        setState(() {
                          showPastEvents = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        itemCount: service.events.length,
        itemBuilder: (context, index) {
          final Event event = service.events[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title),
                Text(event.description),
                Text(event.date.toString()),
                Text(event.price.toString()),
                event.image.isNotEmpty
                  ? (event.image.startsWith('http')
                    ? Image.network(
                        event.image,
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                      )
                  : Image.file(
                      File(event.image),
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                    ))
                  : const Icon(
                    Icons.image_outlined,
                    size: 200,
                    color: Colors.grey,
                  ),
                IconButton(
                  icon: Icon(
                    event.isFavorite ? Icons.star : Icons.star_border,
                    color: event.isFavorite ? Colors.amber : null,
                  ),
                  onPressed: () {
                    setState(() {
                      service.markFavorite(event);
                    });
                  },
                ), 
              ],
            ),
          );
        }
      )
    );
  }

  /* Aplicar los diferentes filtros */ 
  List<Event> get filteredEvents {
    var list = [...events]; 
   
    if (showOnlyFavorites) {
      list = list.where((e) => e.isFavorite).toList();
    }

    if (!showPastEvents) {
      final now = DateTime.now();
      list = list.where((e) => e.date.isAfter(now)).toList();
    }

    if (sortByDate) {
      list.sort((a, b) => a.date.compareTo(b.date));
    } 
    
    if (sortByPrice) {
      list.sort((a, b) => a.price.compareTo(b.price)); 
    }

    return list;
  }
}
