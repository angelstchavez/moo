import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/contentBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/editBatch.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';

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

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      setState(() {
        filteredBatches = filterBatches(allBatches, textController.text);
      });
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

  Future<String> finca() async {
    List<Map<String, dynamic>> fincas = await getFincas();
    String fincaID = fincas[0]['nombre'];
    return 'Finca ${fincaID}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: FutureBuilder<String>(
          future: finca(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return AnimationSearchBar(
                backIconColor: Colors.black,
                isBackButtonVisible: false,
                centerTitle: snapshot.data ?? 'Finca',
                onChanged: (text) {
                  setState(() {
                    filteredBatches = filterBatches(allBatches, text);
                  });
                },
                hintText: 'Buscar...',
                searchTextEditingController: textController,
                horizontalPadding: 5,
                searchIconColor: Colors.black,
                
              );
            }
          },
        ),
      ),
      body: FutureBuilder(
        future: getLotesByUser(),
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
          } else if (snapshot.data == null || (snapshot.data as List).isEmpty) {
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
            allBatches = snapshot.data as List<Map<String, dynamic>>;
            filteredBatches = filterBatches(allBatches, textController.text);

            filteredBatches.sort((a, b) {
              int compareByCantidad =
                  (b['cantidad'] ?? 0).compareTo(a['cantidad'] ?? 0);
              if (compareByCantidad != 0) {
                return compareByCantidad;
              } else {
                return a['nombre'].compareTo(b['nombre']);
              }
            });
            return ListView.builder(
              itemCount: filteredBatches.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Dismissible(
                    background: Container(
                      color: Colors.red,
                      alignment: AlignmentDirectional.centerEnd,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      await deleteBatch(filteredBatches[index]["uid"]);
                    },
                    confirmDismiss: (direction) async {
                      bool result = false;

                      if (filteredBatches[index]['cantidad'] == null ||
                          filteredBatches[index]['cantidad'] == 0) {
                        result = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Icon(Icons.warning_amber_rounded),
                                iconColor: Colors.yellow,
                                content: Text(
                                    '¿Está seguro de eliminar a ${filteredBatches[index]["nombre"]}?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        return Navigator.pop(context, false);
                                      },
                                      child: const Text('Cancelar',
                                          style: TextStyle(color: Colors.red))),
                                  TextButton(
                                      onPressed: () {
                                        showToast(
                                            message:
                                                'Lote eliminado exitosamente');
                                        return Navigator.pop(context, true);
                                      },
                                      child: const Text('Aceptar'))
                                ],
                              );
                            });
                      } else {
                        result = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Icon(Icons.info),
                                iconColor: Colors.yellow,
                                iconPadding: const EdgeInsets.all(50),
                                content: Text(
                                    'No puedes eliminar el "${filteredBatches[index]["nombre"]}"\nPorque tiene ${filteredBatches[index]["cantidad"].toString()} Animales'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        return Navigator.pop(context, false);
                                      },
                                      child: const Text('OK',
                                          style:
                                              TextStyle(color: Colors.blue))),
                                ],
                              );
                            });
                      }

                      return result;
                    },
                    key: Key(filteredBatches[index]["uid"]),
                    child: ListTile(
                      leading: CircleAvatar(
                          radius: 27,
                          backgroundImage: filteredBatches[index]['img'] == null
                              ? const NetworkImage(
                                  'https://acortar.link/twXsOQ')
                              : NetworkImage(
                                  '${filteredBatches[index]['img']}')),
                      onTap: () async {
                        String nombreLote = filteredBatches[index]["nombre"];
                        String? imagen = filteredBatches[index]["img"];

                        String idLote = filteredBatches[index]["uid"];
                        List<Map<String, dynamic>> fincas = await getFincas();
                        String finca = fincas[0]['uid'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContentBatch(
                                  nombre: nombreLote,
                                  id: idLote,
                                  finca: finca,
                                  img: imagen)),
                        ).then((value) => setState(() {}));
                      },
                      title: Text(filteredBatches[index]["nombre"]),
                      subtitle: Text(
                          filteredBatches[index]['cantidad'].toString() ?? ''),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String value) async {
                          if (value == 'Editar') {
                            String nombreLote =
                                filteredBatches[index]["nombre"];
                            int cantidadLote =
                                filteredBatches[index]["cantidad"];
                            String idLote = filteredBatches[index]["uid"];

                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return EditBatch(
                                  nombre: nombreLote,
                                  cantidad: cantidadLote,
                                  id: idLote,
                                );
                              },
                            );
                            setState(() {});
                          } else {
                            await deleteBatch(filteredBatches[index]["uid"]);
                          }
                        },
                        color: const Color.fromARGB(255, 201, 143, 122),
                        elevation: 5,
                        iconSize: 20,
                        shadowColor: Colors.black,
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Editar',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Editar'),
                            ),
                          ),
                          
                          
                        ],
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
