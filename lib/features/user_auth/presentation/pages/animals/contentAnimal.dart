import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:moo/features/user_auth/presentation/pages/production/addProduction.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/service_produccion.dart';

class ContentAnimal extends StatefulWidget {
  final String nombre;
  final String id;
  final String? img;
  const ContentAnimal(
      {Key? key, required this.nombre, required this.id, required this.img})
      : super(key: key);

  @override
  State<ContentAnimal> createState() => _ContentAnimalState();
}

class _ContentAnimalState extends State<ContentAnimal> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> allProduction = [];
  List<Map<String, dynamic>> filteredProductions = [];

  int dataLength = 0;

  List<Map<String, dynamic>> filterProduction(
      List<Map<String, dynamic>> animals, String searchText) {
    return animals.where((animal) {
      final animalName = animal['nombre'].toString().toLowerCase();
      final searchLower = searchText.toLowerCase();
      return animalName.contains(searchLower);
    }).toList();
  }

  Future<void> loadData() async {
    var data = await getProductionByAnimal(widget.id);
    setState(() {
      dataLength = data.length;
      allProduction = data;
      filteredProductions =
          filterProduction(allProduction, textController.text);
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
    textController.addListener(() {
      setState(() {
        filteredProductions =
            filterProduction(allProduction, textController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcular la suma de 'cantidad'
    final totalCantidad = filteredProductions.fold<double>(
      0,
      (previousValue, element) {
        final cantidad = element['cantidad'] as num? ?? 0;
        return previousValue + cantidad.toDouble();
      },
    );

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
                        filteredProductions =
                            filterProduction(allProduction, text);
                      });
                    },
                    searchTextEditingController: textController,
                    horizontalPadding: 5,
                    searchIconColor: Colors.white,
                  )))),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: widget.img != null
                          ? Image.network('${widget.img}', fit: BoxFit.cover)
                          : Image.network('https://acortar.link/hrux2P',
                              fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Text('Total Cantidad: $totalCantidad Litros',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: FutureBuilder(
                future: getProductionByAnimal(widget.id),
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
                            onPressed: () async {},
                            icon: const Icon(Icons.add),
                            iconSize: 70,
                            color: Colors.grey,
                          ),
                          const Text('No se encontraron datos',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.grey)),
                        ],
                      ),
                    );
                  } else {
                    dataLength = (snapshot.data as List).length;
                    allProduction = snapshot.data as List<Map<String, dynamic>>;
                    filteredProductions =
                        filterProduction(allProduction, textController.text);

                    filteredProductions.sort((a, b) {
                      int compareByProduccion =
                          (b['cantidad'] ?? 0).compareTo(a['cantidad'] ?? 0);
                      if (compareByProduccion != 0 ||
                          compareByProduccion != null) {
                        return compareByProduccion;
                      } else {
                        return a['nombre'].compareTo(b['nombre']);
                      }
                    });
                    return ListView.builder(
                      itemCount: filteredProductions.length,
                      itemBuilder: (BuildContext context, int index) {
                        final produccion = filteredProductions[index];
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
                                direction:
                                    currentUser.displayName != 'trabajador'
                                        ? DismissDirection.horizontal
                                        : DismissDirection.startToEnd,
                                onDismissed: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    // Manejo de la edición
                                  }
                                },
                                confirmDismiss: (direction) async {
                                  bool result = false;
                                  
                                  String fechaP = produccion['fecha'];
                                  String idProduccion = produccion['uid'];
                                  double cantidadProduccion = produccion['cantidad'];
                                 

                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    result = false;
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => EditAnimal(
                                    //             fechaN: fechaAnimal,
                                    //             nombre: nombreAnimal,
                                    //             id: idAnimal,
                                    //             img: imgAnimal,
                                    //             parto: partoAnimal,
                                    //             finca: finca,
                                    //           )),
                                    // ).then((value) => setState(() {}));
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
                                            '¿Está seguro de eliminar la produccion del dia $fechaP?',
                                            style:
                                                const TextStyle(fontSize: 20),
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
                                                await deleteProduccion(idProduccion)
                                                    .then(
                                                  (value) {
                                                    setState(() {
                                                      
                                                      updateAnimalProduccion(widget.id, totalCantidad-cantidadProduccion);
                                                      loadData();
                                                    });
                                                  },
                                                );
                                                showToast(
                                                    message:
                                                        'produccion eliminada exitosamente');
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
                                key: Key(filteredProductions[index]["uid"]),
                                child: ListTile(
                                  onTap: () async {},
                                  title: Text(
                                      '${filteredProductions[index]["cantidad"].toString() ?? ''} Litros'),
                                  subtitle: Text(
                                      'Fecha: ${filteredProductions[index]["fecha"]}'),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 201, 143, 122),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddProduction(
                animal: widget.id,
                tLitros: totalCantidad,
              );
            },
          );
          setState(() {
            loadData();
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
