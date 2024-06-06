import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moo/features/user_auth/presentation/pages/AddTrabajdor.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/editBatch.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Farm.dart';
import 'package:moo/services/firebase_user.dart';

class TrbajadorTab extends StatefulWidget {
  const TrbajadorTab({super.key});

  @override
  State<TrbajadorTab> createState() => _TrbajadorTabState();
}

class _TrbajadorTabState extends State<TrbajadorTab> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> allTrabajadores = [];
  List<Map<String, dynamic>> filteredTrabajadores = [];
  List<Map<String, dynamic>> fincas = [];
  Map<String, dynamic>? user;
  String? userId;
  String? fincaNombre;
  String? fincaId;
  bool userActive = true;

  @override
  void initState() {
    super.initState();
    obtenerUsuarioYFincas();
    textController.addListener(() {
      if (!mounted) return; // Verifica si el widget está montado
      setState(() {
        filteredTrabajadores =
            filterTrabajadores(allTrabajadores, textController.text);
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

  List<Map<String, dynamic>> filterTrabajadores(
      List<Map<String, dynamic>> trabajadores, String searchText) {
    return trabajadores.where((trabajador) {
      final novillaName = trabajador['nombre'].toString().toLowerCase();
      final searchLower = searchText.toLowerCase();
      return novillaName.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUserByJefe(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
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
                      List<Map<String, dynamic>> fincas = await getFincass();
                      String finca = fincas[0]['uid'];

                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddTrabajador(
                            finca: finca,
                            jefe: currentUser.uid,
                          );
                        },
                      );
                      setState(() {
                        obtenerUsuarioYFincas();
                      });
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
            allTrabajadores = snapshot.data!;
            filteredTrabajadores =
                filterTrabajadores(allTrabajadores, textController.text);
            filteredTrabajadores.sort((a, b) {
              int compareByCantidad =
                  (b['cantidad'] ?? 0).compareTo(a['cantidad'] ?? 0);
              return compareByCantidad != 0
                  ? compareByCantidad
                  : a['nombre'].compareTo(b['nombre']);
            });

            return ListView.builder(
              itemCount: filteredTrabajadores.length,
              itemBuilder: (BuildContext context, int index) {
                final trabajador = filteredTrabajadores[index];
                return SizedBox(
                  height: 80,
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
                        String nombreTrabajador = trabajador['nombre'];
                        String? imgTrabjador = trabajador['img'];
                        String idTrabajador = trabajador['uid'].toString();
                        

                        if (direction == DismissDirection.startToEnd) {
                          result = false;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBatch(
                                nombre: nombreTrabajador,
                                id: idTrabajador,
                                img: imgTrabjador,
                              ),
                            ),
                          ).then((value) {
                            if (!mounted)
                              return; // Verifica si el widget está montado
                            setState(() {});
                          });
                        } else {
                          
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
                                    '¿Está seguro de eliminar a $nombreTrabajador?',
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
                                        await deleteUser(idTrabajador).then((value) {
                                          
                                          if (!mounted)
                                            return; // Verifica si el widget está montado
                                          setState(() {});
                                        });
                                        showToast(
                                            message:
                                                'Trabajador eliminado exitosamente');
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
                          } 
                        
                        if (!mounted)
                          return result; // Verifica si el widget está montado
                        setState(() {});
                        return result;
                      },
                      key: Key(trabajador["uid"]),
                      child: ListTile(
                        leading: Container(
                            width: 60, // Ajusta el tamaño según sea necesario
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.5), // Color de la sombra
                                  spreadRadius:
                                      3, // Radio de expansión de la sombra
                                  blurRadius:
                                      5, // Radio de desenfoque de la sombra
                                  offset: const Offset(0,
                                      3), // Desplazamiento de la sombra (x, y)
                                ),
                              ],
                            ),
                            child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              300.0), // Ajusta el radio según sea necesario
                                        ),
                                        child: Container(
                                          alignment: Alignment.topCenter,
                                          width: 300,
                                          height: 300,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                150.0), // Ajusta el radio según sea necesario
                                            image: DecorationImage(
                                              image: trabajador['img'] == null
                                                  ? const AssetImage(
                                                      'assets/icon/granjeroI.png')
                                                  : trabajador['img'] is String
                                                      ? NetworkImage(
                                                          trabajador['img'])
                                                      : trabajador['img']
                                                              is ImageProvider
                                                          ? trabajador['img']
                                                          : null,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: trabajador['img'] == null
                                      ? const AssetImage(
                                          'assets/icon/granjeroI.png')
                                      : trabajador['img'] is String
                                          ? NetworkImage(trabajador['img'])
                                          : trabajador['img'] is ImageProvider
                                              ? trabajador['img']
                                              : null,
                                ))),
                        hoverColor: Colors.green.shade50,
                        onTap: () async {
                          String idNovilla = trabajador['uid'];
                          String idNombre = trabajador['nombre'];
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
                                // content: Text(
                                //   '¿Está seguro de añadir a $idNombre al lote ${widget.nombreLote}?',
                                //   style: const TextStyle(fontSize: 20),
                                // ),
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
                                      // await updateLote(idNovilla,widget.idLote).then((value) {
                                      //   if (!mounted)
                                      //     return; // Verifica si el widget está montado
                                      //   setState(() {});
                                      // });
                                      // showToast(
                                      //     message:
                                      //         'Novilla $idNombre Añadida exitosamente');
                                      // Navigator.pop(context, true);
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
                        title: Text(
                            '${trabajador["nombre"]} ${trabajador['apellido']} '),
                        subtitle: Text(trabajador['rol']),
                        trailing: // Espaciado flexible para empujar el switch hacia la derecha
                            Switch(
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey,
                          value: userActive = trabajador['state'],
                          onChanged: (value) async {
                            setState(() {
                              userActive = value; // Actualiza el valor de parto
                            });
                            updateStateUser(trabajador['uid'], userActive);
                            Fluttertoast.showToast(
                              msg: 'Trabajador Exitoso...',
                              backgroundColor: Colors.green,
                              webPosition: 'left',
                              fontSize: 20,
                            );
                          },
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 46, 87, 28),
        onPressed: () async {
          List<Map<String, dynamic>> fincas = await getFincass();
          String finca = fincas[0]['uid'];

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddTrabajador(
                finca: finca,
                jefe: currentUser.uid,
              );
            },
          );
          setState(() {
            obtenerUsuarioYFincas();
          });
        },
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 37,
        ),
      ),
    );
  }


}
