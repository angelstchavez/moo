import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:moo/services/firebase_service_Farm.dart';

class FarmTab extends StatefulWidget {
  const FarmTab({Key? key}) : super(key: key);

  @override
  State<FarmTab> createState() => _FarmTabState();
}

class _FarmTabState extends State<FarmTab> {
    final currentUser = FirebaseAuth.instance.currentUser!;
    
  List<Map<String, dynamic>> fincas = []; // Lista para almacenar todas las fincas
  obtenerFincas() async {
    List<Map<String, dynamic>> fetchedFincas = await getFincas();
    setState(() {
      fincas = fetchedFincas; // Actualizar el estado del widget con las fincas obtenidas
    });
  }
  @override
  void initState() {
    super.initState();
    obtenerFincas(); // Llamar a la función para obtener las fincas al inicializar el widget
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: fincas.length,
        itemBuilder: (context, index) {
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 170,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column( // Cambiado de Row a Column
                    crossAxisAlignment: CrossAxisAlignment.start, // Alineados a la izquierda
                    children: [
                      const Icon(Icons.home_outlined),
                      Text(
                        'Finca:      ${fincas[index]['nombre'].toString().capitalize}',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        'Tamaño: ${fincas[index]['tamano']} Hectareas',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        'Propietario: ${currentUser.displayName.toString().capitalize}',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        'Email: ${currentUser.email} ',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
