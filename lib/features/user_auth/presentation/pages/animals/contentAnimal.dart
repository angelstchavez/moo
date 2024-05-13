import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ContentAnimal extends StatefulWidget {
  final String nombre;

  final String id;
  final String? img;
  const ContentAnimal(
      {Key? key, required this.nombre, required this.id, required this.img})
      : super(key: key);

  @override
  State<ContentAnimal> createState() => _ContentAnimalState();
}

class _ContentAnimalState extends State<ContentAnimal> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // Método para cargar los datos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        //actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back_ios_new))],
        title: Text(widget.nombre),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio:
                          16 / 9, // Proporción deseada (puedes ajustarla)
                      child: widget.img != null
                          ? Image.network('${widget.img}', fit: BoxFit.cover)
                          : Image.network('https://acortar.link/hrux2P',
                              fit: BoxFit.cover),
                    ),
                    const SizedBox(
                        height: 8), // Espacio entre la imagen y el texto
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
