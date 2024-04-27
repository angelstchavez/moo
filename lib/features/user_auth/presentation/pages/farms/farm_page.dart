import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/editBatch.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';

class FarmPage extends StatefulWidget {
  const FarmPage({Key? key}) : super(key: key);

  @override
  State<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
    final  currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(currentUser.uid),
      ),
      body: FutureBuilder(
        future: getFincas(),
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
          } else if (snapshot.data == null) {
            return const Center(
              child: Text('No se encontraron datos'),
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
                                      return Navigator.pop(context, true);
                                    },
                                    child: const Text('Aceptar'))
                              ],
                            );
                          });

                      return result;
                    },
                    key: Key(snapshot.data?[index]["uid"]),
                    child: ListTile(
                      leading: const Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.add_box,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                      title: Text(snapshot.data?[index]["nombre"]),
                      
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
                          }else{
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
