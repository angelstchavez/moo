import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/contentBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/editBatch.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';
import 'package:moo/services/firebase_user.dart';

class BatchPage extends StatefulWidget {
  const BatchPage({Key? key}) : super(key: key);

  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> allBatches = [];
  List<Map<String, dynamic>> filteredBatches = [];
  List<Map<String, dynamic>> fincas = [];
  Map<String, dynamic>? user;
  String? userId;
  String? finca;
  String? fincaiD;

  @override
  void initState() {
    super.initState();
    obtenerUsuarioYFincas();
    textController.addListener(() {
      if (!mounted) return; // Verifica si el widget está montado
      setState(() {
        filteredBatches = filterBatches(allBatches, textController.text);
      });
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> obtenerUsuarioYFincas() async {
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
      finca = fetchedFincas.isNotEmpty ? fetchedFincas[0]['nombre'] : null;
      fincaiD = fetchedFincas.isNotEmpty ? fetchedFincas[0]['uid'] : null;
    });
  }

  List<Map<String, dynamic>> filterBatches(
      List<Map<String, dynamic>> batches, String searchText) {
    return batches.where((batch) {
      final batchName = batch['nombre'].toString().toLowerCase();
      final searchLower = searchText.toLowerCase();
      return batchName.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: AnimationSearchBar(
            backIconColor: Colors.black,
            isBackButtonVisible: false,
            centerTitle: finca ?? 'Finca',
            onChanged: (text) {
              if (!mounted) return; // Verifica si el widget está montado
              setState(() {
                filteredBatches = filterBatches(allBatches, text);
              });
            },
            hintText: 'Buscar...',
            searchTextEditingController: textController,
            horizontalPadding: 5,
            searchIconColor: Colors.black,
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: getLotesByUser(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                  backgroundColor: Colors.blueAccent,
                  strokeWidth: 5,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddBatch(
                              fincaId: '$fincaiD',
                            );
                          },
                        ).then((value) {
                          if (!mounted)return; // Verifica si el widget está montado
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.add),
                      iconSize: 70,
                      color: Colors.grey,
                    ),
                    const Text(
                      'No se encontraron datos',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else {
              allBatches = snapshot.data!;
              filteredBatches = filterBatches(allBatches, textController.text);
              filteredBatches.sort((a, b) {
                int compareByCantidad =
                    (b['cantidad'] ?? 0).compareTo(a['cantidad'] ?? 0);
                return compareByCantidad != 0
                    ? compareByCantidad
                    : a['nombre'].compareTo(b['nombre']);
              });

              return ListView.builder(
                itemCount: filteredBatches.length,
                itemBuilder: (BuildContext context, int index) {
                  final batch = filteredBatches[index];
                  return Card(
                    color: Colors.grey.shade200,
                    child: Dismissible(
                      background: Container(
                        color: Colors.blue,
                        alignment: AlignmentDirectional.centerStart,
                        padding: const EdgeInsets.only(left: 15),
                        child: const Icon(
                          Icons.edit_square,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: AlignmentDirectional.centerEnd,
                        padding: const EdgeInsets.only(right: 15),
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      direction: currentUser.displayName != 'trabajador'
                          ? DismissDirection.horizontal
                          : DismissDirection.startToEnd,
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Manejo de la edición
                        }
                      },
                      confirmDismiss: (direction) async {
                        bool result = false;
                        String nombreLote = batch['nombre'];
                        String? imgLote = batch['img'];
                        String idLote = batch['uid'].toString();
                        int cantidad = batch['cantidad'];

                        if (direction == DismissDirection.startToEnd) {
                          result = false;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBatch(
                                nombre: nombreLote,
                                id: idLote,
                                img: imgLote,
                              ),
                            ),
                          ).then((value) {
                            if (!mounted)
                              return; // Verifica si el widget está montado
                            setState(() {});
                          });
                        } else {
                          if (batch['cantidad'] == 0) {
                            result = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Icon(
                                    Icons.question_mark_rounded,
                                    size: 50,
                                    color: Colors.blue,
                                  ),
                                  iconColor: Colors.red,
                                  content: Text(
                                    '¿Está seguro de eliminar a $nombreLote?',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await deleteBatch(idLote).then((value) {
                                          if (!mounted)
                                            return; // Verifica si el widget está montado
                                          setState(() {});
                                        });
                                        showToast(
                                            message:
                                                'Lote eliminado exitosamente');
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text(
                                        'Aceptar',
                                        style: TextStyle(
                                            color: Colors.green, fontSize: 20),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            result = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Icon(
                                    Icons.info,
                                    size: 50,
                                    color: Colors.amber,
                                  ),
                                  iconColor: Colors.yellow,
                                  content: Text(
                                    'No puedes eliminar el "$nombreLote"\nPorque tiene $cantidad Animales',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 20),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                        if (!mounted)
                          return result; // Verifica si el widget está montado
                        setState(() {});
                        return result;
                      },
                      key: Key(batch["uid"]),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 40,
                          backgroundImage: batch['img'] == null
                              ? const NetworkImage(
                                  'https://acortar.link/twXsOQ')
                              : NetworkImage(batch['img']),
                        ),
                        hoverColor: Colors.green.shade50,
                        onTap: () async {
                          String nombreLote = batch["nombre"];
                          String? imagen = batch["img"];
                          String idLote = batch["uid"];
                          List<Map<String, dynamic>> fetchedFincas =
                              await getFincas(userId);
                          String fetchedFinca = fetchedFincas.isNotEmpty
                              ? fetchedFincas[0]['uid']
                              : '';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContentBatch(
                                nombre: nombreLote,
                                id: idLote,
                                finca: fetchedFinca,
                                img: imagen,
                              ),
                            ),
                          ).then((value) {
                            if (!mounted)
                              return; // Verifica si el widget está montado
                            setState(() {});
                          });
                        },
                        title: Text(
                          batch["nombre"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: batch['cantidad'] == 0
                            ? Text('No tiene animales...')
                            : Text(batch['cantidad'].toString() ?? ''),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 46, 87, 28),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddBatch(
                  fincaId: '$fincaiD',
                );
              },
            ).then((value) {
              if (!mounted) return; // Verifica si el widget está montado
              setState(() {});
            });
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
