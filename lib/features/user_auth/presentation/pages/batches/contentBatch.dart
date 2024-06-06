import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/addAnimal.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/contentAnimal.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/editAnimal.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/novillas_page.dart';

import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/batch_page.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';
//import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

class ContentBatch extends StatefulWidget {
  final String nombre;
  final String finca;
  final String id;
  final String? img;
  const ContentBatch(
      {Key? key,
      required this.nombre,
      required this.id,
      required this.finca,
      required this.img})
      : super(key: key);

  @override
  State<ContentBatch> createState() => _ContentBatchState();
}

class _ContentBatchState extends State<ContentBatch> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> allAnimals = [];
  List<Map<String, dynamic>> filteredAnimals = [];

  int dataLength = 0;

  List<Map<String, dynamic>> filterAnimals(
      List<Map<String, dynamic>> animals, String searchText) {
    return animals.where((animal) {
      final animalName = animal['nombre'].toString().toLowerCase();
      final searchLower = searchText.toLowerCase();
      return animalName.contains(searchLower);
    }).toList();
  }

  // Método para cargar los datos
  Future<void> loadData() async {
    var data = await getVacasByLote(widget.id);
    setState(() {
      dataLength = data.length;
      updateBatchLenght(widget.id, dataLength);
    });
  }

  @override
  void initState() {
    super.initState();

    loadData(); // Método para cargar los datos al abrir la página
    textController.addListener(() {
      setState(() {
        filteredAnimals = filterAnimals(allAnimals, textController.text);
      });
    });
  }

  double? h;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 65),
          child: SafeArea(
              child: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(46, 125, 50, 1),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 0,
                            offset: Offset(0, 5))
                      ]),
                  alignment: Alignment.center,
                  child: AnimationSearchBar(
                    backIconColor: Colors.white,
                    centerTitle: widget.nombre.toString().capitalizeFirst,
                    centerTitleStyle:
                        const TextStyle(color: Colors.white, fontSize: 25),
                    onChanged: (text) {
                      setState(() {
                        filteredAnimals = filterAnimals(allAnimals, text);
                      });
                    },
                    searchTextEditingController: textController,
                    horizontalPadding: 5,
                    searchIconColor: Colors.white,
                  )))),
      body: Column(
        children: [
          SizedBox(
            height: h,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Card(
                  color: Colors.lightGreen,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: widget.img != null
                              ? Image.network('${widget.img}',
                                  fit: BoxFit.cover)
                              : Image.network('https://acortar.link/m8RozS',
                                  fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dataLength != null
                              ? 'Total de animales: $dataLength'
                              : '0',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getVacasByLote(widget.id),
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
                } else if (snapshot.data == null ||
                    (snapshot.data as List).isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            // await showDialog(
                            //   context: context,
                            //   builder: (BuildContext context) {
                            //     return const AddBatch();
                            //   },
                            // );
                            // setState(() {});
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
                  dataLength = (snapshot.data as List).length;
                  allAnimals = snapshot.data as List<Map<String, dynamic>>;
                  filteredAnimals =
                      filterAnimals(allAnimals, textController.text);

                  filteredAnimals.sort((a, b) {
                    int compareByProduccion =
                        (b['produccion'] ?? 0).compareTo(a['produccion'] ?? 0);
                    if (compareByProduccion != 0) {
                      return compareByProduccion;
                    } else {
                      return a['nombre'].compareTo(b['nombre']);
                    }
                  });
                  return ListView.builder(
                    itemCount: filteredAnimals.length,
                    itemBuilder: (BuildContext context, int index) {
                      final animal = filteredAnimals[index];
                      return Column(
                        children: [
                          Card(
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
                                String nombreAnimal = animal['nombre'];
                                String razaAnimal = animal['raza'];
                                bool partoAnimal = animal['esMadre'];
                                String? imgAnimal = animal['img'];
                                String idAnimal = animal['uid'].toString();
                                String fechaAnimal = animal['fecha'];
                                String finca = animal['finca'];

                                if (direction == DismissDirection.startToEnd) {
                                  result = false;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditAnimal(
                                              raza: razaAnimal,
                                              fechaN: fechaAnimal,
                                              nombre: nombreAnimal,
                                              id: idAnimal,
                                              img: imgAnimal,
                                              parto: partoAnimal,
                                              finca: finca,
                                            )),
                                  ).then((value) => setState(() {}));
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
                                          '¿Está seguro de eliminar a $nombreAnimal?',
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
                                                  color: Colors.red,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await deleteAnimal(idAnimal).then(
                                                (value) {
                                                  setState(() {});
                                                },
                                              );
                                              showToast(
                                                  message:
                                                      'Animal eliminado exitosamente');
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text(
                                              'Aceptar',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                                setState(() {});
                                return result;
                              },
                              key: Key(filteredAnimals[index]["uid"]),
                              child: ListTile(
                                leading: CircleAvatar(
                                    radius: 27,
                                    backgroundImage: filteredAnimals[index]
                                                ['img'] ==
                                            null
                                        ? const NetworkImage(
                                            'https://acortar.link/hrux2P')
                                        : NetworkImage(
                                            '${filteredAnimals[index]['img']}')),
                                onTap: () async {
                                  String nombreAnimal =
                                      filteredAnimals[index]["nombre"];
                                  String razaAnimal =
                                      filteredAnimals[index]["raza"];
                                  String? imgAnimal =
                                      filteredAnimals[index]["img"];
                                  String idAnimal =
                                      filteredAnimals[index]["uid"];
                                  String fechaAnimal =
                                      filteredAnimals[index]["fecha"];
                                  bool parto = filteredAnimals[index]["parto"];
                                  int edadTernero =
                                      filteredAnimals[index]["edadTernero"];
                                  String finca =
                                      filteredAnimals[index]['finca'];

                                  if (parto) {
                                    if (edadTernero < 1) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ContentAnimal(
                                                nombre: nombreAnimal,
                                                id: idAnimal,
                                                img: imgAnimal)),
                                      );
                                    }
                                  } else {
                                    await showDialog(
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
                                            'No puedes agregarle produccion a la vaca $nombreAnimal porque no tiene un parto, ve a a editar y agrega un parto',
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditAnimal(
                                                            raza: razaAnimal,
                                                            fechaN: fechaAnimal,
                                                            nombre:
                                                                nombreAnimal,
                                                            id: idAnimal,
                                                            img: imgAnimal,
                                                            parto: parto,
                                                            finca: finca,
                                                          )),
                                                ).then((value) => setState(() {
                                                      Navigator.pop(context);
                                                    }));
                                              },
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 20),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 20),
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                title: Text(filteredAnimals[index]["nombre"]),
                                subtitle: Text(filteredAnimals[index]["raza"]),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 46, 87, 28),
        onPressed: () async {
          await showDialog(
            
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Selecciona una opción'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Añadir Animal'),
                      onTap: () {
                        Navigator.pop(context); // Cerrar el diálogo
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AddAnimal(
                              lote: widget.id,
                              finca: widget.finca,
                              dataLength: dataLength,
                            );
                          },
                          
                        ).then((value) {
                          setState(() {
                            loadData();
                          });
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.select_all),
                      title: const Text('Seleccionar Novilla'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NovillaPage(
                                    idLote: widget.id,
                                    nombreLote: widget.nombre,
                                  )),
                        ).then((value) => setState(() {
                              Navigator.pop(context);
                            }));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
