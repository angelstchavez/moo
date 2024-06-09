import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:moo/features/user_auth/presentation/pages/trabajador/AddTrabajdor.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/editBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/trabajador/edit_trabajador.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Farm.dart';
import 'package:moo/services/firebase_user.dart';

class TrabajadorTab extends StatefulWidget {
  const TrabajadorTab({super.key});

  @override
  State<TrabajadorTab> createState() => _TrabajadorTabState();
}

class _TrabajadorTabState extends State<TrabajadorTab> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController textController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  List<Map<String, dynamic>> allTrabajadores = [];
  List<Map<String, dynamic>> filteredTrabajadores = [];
  List<Map<String, dynamic>> fincas = [];
  Map<String, dynamic>? user;
  String? userId;
  String? fincaNombre;
  String? fincaId;
  bool userActive = true;
  bool isEditing = false;

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

  final _formKey = GlobalKey<FormState>();

  void _showEditModal(BuildContext context, String id, String nombre,
      String apellido, String email, String telefono, String? img) async {
    _nombreController.text = nombre;
    _apellidoController.text = apellido;
    _telefonoController.text = telefono;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 200,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Información Trabajador',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(16),
                        img != null
                            ? CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(img),
                              )
                            : const CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    AssetImage('assets/icon/granjeroI.png'),
                              ),
                        Text(
                          email,
                          style: const TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(16),
                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.green.shade50),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.lime,
                            ),
                          ),
                          title: const Text('Editar'),
                          trailing: Switch(
                            activeColor: Colors.white,
                            activeTrackColor: Colors.green,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey,
                            value: isEditing,
                            onChanged: (value) {
                              setState(() {
                                isEditing = value;
                              });
                              setModalState(() {
                                isEditing = value;
                              });
                              Fluttertoast.showToast(
                                msg: isEditing
                                    ? 'Editable...'
                                    : 'No editable...',
                                backgroundColor:
                                    isEditing ? Colors.green : Colors.red,
                                webPosition: 'left',
                                fontSize: 20,
                              );
                            },
                          ),
                        ),
                        const Gap(16),
                        TextFormField(
                          readOnly: !isEditing,
                          maxLength: 15,
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'nombre',
                            hintText: 'ingrese el nombre',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 20),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese el nombre';
                            }
                            return null;
                          },
                        ),
                        const Gap(16),
                        TextFormField(
                          readOnly: !isEditing,
                          maxLength: 15,
                          controller: _apellidoController,
                          decoration: InputDecoration(
                            labelText: 'apellido',
                            hintText: 'ingrese el apellido',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 20),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese el apellido';
                            }
                            return null;
                          },
                        ),
                        const Gap(16),
                        TextFormField(
                          readOnly: !isEditing,
                          maxLength: 15,
                          controller: _telefonoController,
                          decoration: InputDecoration(
                            labelText: 'telefono',
                            hintText: 'ingrese el telefono',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 20),
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            floatingLabelStyle:
                                const TextStyle(color: Colors.black),
                            hintStyle: const TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese el telefono';
                            }
                            return null;
                          },
                        ),
                        isEditing == true
                            ? ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green.shade800),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await updateUser(
                                      id,
                                      _nombreController.text,
                                      _apellidoController.text,
                                      _telefonoController.text.trim(),
                                    ).then((_) {
                                      setState(() {
                                        obtenerUsuarioYFincas();
                                        isEditing = false;
                                        Navigator.pop(context);
                                      });

                                      showToast(
                                          message:
                                              'Usuario Actualizado con exito!!!');
                                    });
                                  }
                                  setState(() {});
                                },
                                child: const Text(
                                  'ACTUALIZAR',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ))
                            : const Text(''),
                        const Gap(20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUserByJefe(),
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
                editTrabajador() async {
                  _showEditModal(
                    context,
                    trabajador['uid'],
                    trabajador['nombre'],
                    trabajador['apellido'],
                    trabajador['email'],
                    trabajador['telefono'],
                    trabajador['img'],
                  );
                  setState(() {
                    obtenerUsuarioYFincas();
                  });
                  return Future<bool>.value(false);
                }

                deleteTrabajador() async {
                  bool result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Icon(
                          Icons.question_mark_rounded,
                          size: 50,
                          color: Colors.grey,
                        ),
                        iconColor: Colors.red,
                        content: Text(
                          '¿Está seguro de eliminar a ${trabajador['nombre']}?',
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await deleteUser(trabajador['uid']).then((value) {
                                if (!mounted)
                                  return; // Verifica si el widget está montado
                                setState(() {});
                              });
                              showToast(
                                  message: 'Trabajador eliminado exitosamente');
                              Navigator.pop(context, true);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.limeAccent),
                            child: const Text(
                              'Aceptar',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  // Verifica si el widget está montado
                  setState(() {
                    obtenerUsuarioYFincas();
                  });
                  return result;
                }

                return SizedBox(
                  height: 80,
                  child: Card(
                    child: Slidable(
                      key: Key(trabajador["uid"]),
                      startActionPane: ActionPane(
                        dismissible: DismissiblePane(
                          onDismissed: () {},
                          confirmDismiss: () {
                            return editTrabajador();
                          },
                        ),
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                            autoClose: true,
                            onPressed: (context) {
                              // Aquí puedes manejar la acción de "Editar" del Slidable
                              editTrabajador();
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Editar',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const StretchMotion(),
                        dismissible: DismissiblePane(
                          onDismissed: () {},
                          confirmDismiss: () async {
                            return deleteTrabajador();
                          },
                        ),
                        children: [
                          SlidableAction(
                            onPressed: (context) => deleteTrabajador(),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_forever,
                            label: 'Eliminar',
                          ),
                        ],
                      ),
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
                                offset: const Offset(
                                    0, 3), // Desplazamiento de la sombra (x, y)
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
                            ),
                          ),
                        ),
                        hoverColor: Colors.green.shade50,
                        title: Text(
                            '${trabajador["nombre"]} ${trabajador['apellido']} '),
                        subtitle: Text(trabajador['rol']),
                        trailing: Switch(
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
