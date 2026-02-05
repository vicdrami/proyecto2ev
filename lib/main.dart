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
  /*@override
  void initState() {
    super.initState();
    //loadFavorites();
  }*/

  /*void loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final service = context.watch<EventsService>();

    return Scaffold(
      appBar: AppBar(title: Text('Listado de eventos')),
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
              ],
            ),
          );
        }
      )
    );
  }
}
