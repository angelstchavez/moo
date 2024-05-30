import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/contentBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/editBatch.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';
import 'package:moo/services/firebase_user.dart';

class NovillaPage extends StatefulWidget {
  final String idLote;
  final String nombreLote;
  const NovillaPage({Key? key, required this.idLote,required this.nombreLote}) : super(key: key);

  @override
  State<NovillaPage> createState() => _NovillaPageState();
}

class _NovillaPageState extends State<NovillaPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> allNovillas = [];
  List<Map<String, dynamic>> filteredNovillas = [];
  List<Map<String, dynamic>> fincas = [];
  Map<String, dynamic>? user;
  String? userId;
  String? fincaNombre;
  String? fincaId;

  @override
  void initState() {
    super.initState();
    obtenerUsuarioYFincas();
    textController.addListener(() {
      if (!mounted) return; // Verifica si el widget está montado
      setState(() {
        filteredNovillas = filterNovillas(allNovillas, textController.text);
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
      fincaNombre =
          fetchedFincas.isNotEmpty ? fetchedFincas[0]['nombre'] : null;
      fincaId = fetchedFincas[0]['uid'];
    });
  }

  List<Map<String, dynamic>> filterNovillas(
      List<Map<String, dynamic>> novillas, String searchText) {
    return novillas.where((novilla) {
      final novillaName = novilla['nombre'].toString().toLowerCase();
      final searchLower = searchText.toLowerCase();
      return novillaName.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: AnimationSearchBar(
          backIconColor: Colors.black,
          isBackButtonVisible: false,
          centerTitle: fincaNombre ?? 'Finca',
          onChanged: (text) {
            if (!mounted) return; // Verifica si el widget está montado
            setState(() {
              filteredNovillas = filterNovillas(allNovillas, text);
            });
          },
          hintText: 'Buscar...',
          searchTextEditingController: textController,
          horizontalPadding: 5,
          searchIconColor: Colors.black,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getNovillasSinLote(fincaId),
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
                          return const AddBatch();
                        },
                      );
                      if (!mounted)
                        return; // Verifica si el widget está montado
                      setState(() {});
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
            allNovillas = snapshot.data!;
            filteredNovillas = filterNovillas(allNovillas, textController.text);
            filteredNovillas.sort((a, b) {
              int compareByCantidad =
                  (b['cantidad'] ?? 0).compareTo(a['cantidad'] ?? 0);
              return compareByCantidad != 0
                  ? compareByCantidad
                  : a['nombre'].compareTo(b['nombre']);
            });

            return ListView.builder(
              itemCount: filteredNovillas.length,
              itemBuilder: (BuildContext context, int index) {
                final novilla = filteredNovillas[index];
                return SizedBox(
                  height: 100,
                  child: Card(
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
                        String nombreLote = novilla['nombre'];
                        String? imgLote = novilla['img'];
                        String idLote = novilla['uid'].toString();
                        int cantidad = novilla['cantidad'];

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
                          if (novilla['cantidad'] == 0) {
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
                      key: Key(novilla["uid"]),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 40,
                          backgroundImage: novilla['img'] == null
                              ? const NetworkImage(
                                  'https://acortar.link/twXsOQ')
                              : NetworkImage(novilla['img']),
                        ),
                        hoverColor: Colors.green.shade50,
                        onTap: () async {
                          String idNovilla = novilla['uid'];
                          String idNombre = novilla['nombre'];
                          await showDialog(
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
                                  '¿Está seguro de añadir a $idNombre al lote ${widget.nombreLote}?',
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
                                      await updateLote(idNovilla,widget.idLote).then((value) {
                                        if (!mounted)
                                          return; // Verifica si el widget está montado
                                        setState(() {});
                                      });
                                      showToast(
                                          message:
                                              'Novilla $idNombre Añadida exitosamente');
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
                        },
                        title: Text(novilla["nombre"]),
                        subtitle: Text(novilla['cantidad'].toString() ?? ''),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 201, 143, 122),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddBatch();
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
    );
  }
}
