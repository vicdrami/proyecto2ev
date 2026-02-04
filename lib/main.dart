import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:proyecto2ev/models/event.dart';
import 'package:proyecto2ev/provider/events_service.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(const MainApp());
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
  @override
  void initState() {
    super.initState();
    //loadFavorites();
  }

  /*void loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final service = context.watch<EventsService>();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Listado de eventos')),
        body: GridView.builder(
          gridDelegate: context,
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
                  Text(event.price.toString())
                  Image(image: event.imageUrl)
                ],
              ),
            );
          }
        )
      ),
    );
  }
}
