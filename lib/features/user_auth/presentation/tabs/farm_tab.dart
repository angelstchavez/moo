import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:moo/services/firebase_service_Farm.dart';
import 'package:moo/services/firebase_user.dart';

class FarmTab extends StatefulWidget {
  const FarmTab({Key? key}) : super(key: key);

  @override
  State<FarmTab> createState() => _FarmTabState();
}

class _FarmTabState extends State<FarmTab> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  Future<List<Map<String, dynamic>>>? _fincasFuture;
  String? fincaNombre;

  @override
  void initState() {
    super.initState();
    _fincasFuture = obtenerUsuarioYFincas();
  }
  
  @override
  void dispose() {
    fincaNombre;
    super.dispose();
    
  }
  


  Future<List<Map<String, dynamic>>> obtenerUsuarioYFincas() async {
    // Obtener la información del usuario
    List<Map<String, dynamic>> usuarios = await getUserByUser();
    if (usuarios.isNotEmpty) {
      setState(() {
        user = usuarios.first;
        users = usuarios.first['idJefe'];
      });
    }
    // Obtener las fincas
    return await getFincas(users);
  }

  Map<String, dynamic>? user;
  String? users; // Variable para almacenar la información del usuario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fincasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron fincas.'));
          } else {
            final fincas = snapshot.data!;
            return ListView.builder(

              itemCount: fincas.length,
              itemBuilder: (context, index) {
                fincaNombre=fincas[index]['nombre'].toString().capitalize;

                return Center(
                  
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 120,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.home_outlined),
                            Text(
                              'Finca: $fincaNombre',
                              style: const TextStyle(fontSize: 18.0),
                            ),
                            Text(
                              'Tamaño: ${fincas[index]['tamano']} Hectareas',
                              style: const TextStyle(fontSize: 18.0),
                            ),
                            
                            
                            
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
