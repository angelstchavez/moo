import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(currentUser.displayName!),
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
                      //Refresh
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
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                // Aquí retornamos un ListTile en lugar de un Text
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
                      await deleteBatch(snapshot.data?[index]["uid"]);
                      //snapshot.data?.removeAt(index);
                    },
                    confirmDismiss: (direction) async {
                      bool result = false;

                      if (snapshot.data?[index]['cantidad'] == null ||
                          snapshot.data?[index]['cantidad'] == 0) {
                        result = await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Icon(Icons.warning_amber_rounded),
                                iconColor: Colors.yellow,
                                content: Text(
                                    '¿Está seguro de eliminar a ${snapshot.data?[index]["nombre"]}'),
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
                                    'No puedes eliminar el "${snapshot.data?[index]["nombre"]}"\nPorque tiene ${snapshot.data?[index]["cantidad"].toString() ?? ''} Animales '),
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
                    key: Key(snapshot.data?[index]["uid"]),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 27,
                        backgroundImage: snapshot.data?[index]
                                                ['img'] ==
                                            null
                                        ? const NetworkImage(
                                            'https://acortar.link/twXsOQ')
                                        : NetworkImage(
                                            '${snapshot.data?[index]['img']}')
                            
                      ),
                      onTap: () async {
                        String nombreLote = snapshot.data?[index]["nombre"];
                        String? imagen = snapshot.data?[index]["img"];

                        String idLote = snapshot.data?[index]["uid"];
                        List<Map<String, dynamic>> fincas = await getFincas();
                        String finca = fincas[0]['uid'];
                        Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContentBatch(
                                    nombre: nombreLote,
                                    id: idLote,
                                    finca: finca,
                                    img: imagen
                                  )),
                        ).then((value) => setState(() {}));
                      },
                      title: Text(snapshot.data?[index]["nombre"]),
                      subtitle: Text(
                          snapshot.data?[index]['cantidad'].toString() ?? ''),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String value) async {
                          if (value == 'Editar') {
                            // Obtener los datos del lote que se está editando
                            String nombreLote = snapshot.data?[index]["nombre"];
                            int cantidadLote =
                                snapshot.data?[index]["cantidad"];
                            String idLote = snapshot.data?[index]["uid"];

                            // Abrir la página de edición pasando los argumentos necesarios
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
                            setState(() {
                              // Puedes agregar lógica de actualización aquí si es necesario
                            });
                          } else {
                            await deleteBatch(snapshot.data?[index]["uid"]);
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
                          const PopupMenuDivider(
                            height: 1,
                          ),
                          const PopupMenuItem<String>(
                            value: 'Eliminar',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Eliminar'),
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
          );
          //Refresh
          setState(() {});
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
