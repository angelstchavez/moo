import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moo/features/user_auth/presentation/pages/trabajador/AddTrabajdor.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/editBatch.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Farm.dart';
import 'package:moo/services/firebase_user.dart';

class AnimalTab extends StatefulWidget {
  const AnimalTab({Key? key});

  @override
  State<AnimalTab> createState() => _AnimalTabState();
}

class _AnimalTabState extends State<AnimalTab> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> allVacas = [];
  List<Map<String, dynamic>> fincas = [];
  Map<String, dynamic>? user;
  String? userId;
  String? fincaNombre;
  String fincaId = '';

  String? nombre;
  String? imageUrl;
  double? produccion;
  String? nombre2;
  String? imageUrl2;
  double? produccion2;
  String? nombre3;
  String? imageUrl3;
  double? produccion3;

  @override
  void initState() {
    super.initState();
    obtenerUsuarioYFincas();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> obtenerUsuarioYFincas() async {
    try {
      List<Map<String, dynamic>> usuarios = await getUserByUser();
      if (usuarios.isNotEmpty) {
        if (!mounted) return; // Verifica si el widget está montado
        setState(() {
          user = usuarios.first;
          userId = usuarios.first['idJefe'];
        });
      }
      List<Map<String, dynamic>> fetchedFincas = await getFincas(userId);

      if (!mounted) return; // Verifica si el widget está montado
      setState(() {
        fincas = fetchedFincas;
        fincaNombre =
            fetchedFincas.isNotEmpty ? fetchedFincas[0]['nombre'] : null;
        fincaId = fetchedFincas.isNotEmpty ? fetchedFincas[0]['uid'] : '';
      });
    } catch (e) {
      // Manejo de errores
      print('Error al obtener usuario y fincas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getVacasByFinca(fincaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || (snapshot.data as List).isEmpty||snapshot.data!.length < 3) {
            return const Center(child: Text('No hay ranking '),);
          } else if (snapshot.hasData) {
            // Ordenar la lista por producción descendente
            snapshot.data!
                .sort((a, b) => b['produccion'].compareTo(a['produccion']));
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 0.8,
                    child: SizedBox(
                      height: 300, // Ajuste de la altura
                      child: Card(
                        color: Colors.blueGrey.shade100,
                        elevation: 5,
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        snapshot.data![1]['img'] != null
                                            ? NetworkImage(
                                                '${snapshot.data![1]['img']}')
                                            : const NetworkImage(
                                                'https://acortar.link/m8RozS'),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    snapshot.data![1]['nombre'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${snapshot.data![1]['produccion'].toString() ?? ''} Litros',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const Positioned(
                              bottom: 3,
                              right: 1,
                              child: Image(
                                image: AssetImage(
                                  'assets/icon/2st.png',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: AspectRatio(
                    aspectRatio: 0.8,
                    child: SizedBox(
                      height: 300, // Ajuste de la altura
                      child: Card(
                        color: Color.fromARGB(209, 255, 214, 64),
                        elevation: 5,
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        snapshot.data![0]['img'] != null
                                            ? NetworkImage(
                                                '${snapshot.data![0]['img']}')
                                            : const NetworkImage(
                                                'https://acortar.link/m8RozS'),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    snapshot.data![0]['nombre'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${snapshot.data![0]['produccion'].toString() ?? ''} Litros',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const Positioned(
                              bottom: 3,
                              right: 1,
                              child: Image(
                                image: AssetImage(
                                  'assets/icon/1st.png',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 0.8,
                    child: SizedBox(
                      height: 300, // Ajuste de la altura
                      child: Card(
                        color: Color.fromARGB(127, 201, 80, 36),
                        elevation: 5,
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage:
                                        snapshot.data![2]['img'] != null
                                            ? NetworkImage(
                                                '${snapshot.data![2]['img']}')
                                            : const NetworkImage(
                                                'https://acortar.link/m8RozS'),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    snapshot.data![2]['nombre'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${snapshot.data![2]['produccion'].toString() ?? ''} Litros',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const Positioned(
                              bottom: 3,
                              right: 1,
                              child: Image(
                                image: AssetImage(
                                  'assets/icon/3st.png',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No hay datos disponibles'));
          }
        },
      ),
    );
  }
}
