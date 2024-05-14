import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:animation_search_bar/animation_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/addAnimal.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/contentAnimal.dart';

import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/batch_page.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';

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
    // Puedes realizar aquí cualquier operación de carga de datos necesaria
    // Por ejemplo, obtener la longitud de los datos o realizar una solicitud al servidor
    var data = await getVacasByLote(widget.id);
    setState(() {
      dataLength = data.length;
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
      appBar:PreferredSize(
        
            preferredSize: const Size(double.infinity, 65),
            child: SafeArea(
              
                child: Container(
                  
              decoration: const BoxDecoration(color: Color.fromRGBO(46, 125, 50, 1), boxShadow: [
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
                  centerTitleStyle: const TextStyle(color: Colors.white,fontSize: 25),
                  onChanged: (text) {
                   setState(() {
                     filteredAnimals = filterAnimals(allAnimals, text);
                   });
               },
                  searchTextEditingController: textController,
                  horizontalPadding: 5,
                  searchIconColor: Colors.white,
                  
                  )
            )
            )
            ), 
      // AppBar(
      //   leading: Row(
      //     children: [
      //       IconButton(
      //         onPressed: () {
      //           Navigator.pop(context);
      //         },
      //         icon: const Icon(Icons.arrow_back_ios_new),
      //       ),
      //       AnimationSearchBar(
      //           backIconColor: Colors.black,
      //           isBackButtonVisible: false,
      //           centerTitle: widget.nombre,
      //           onChanged: (text) {
      //             setState(() {
      //               filteredAnimals = filterAnimals(allAnimals, text);
      //             });
      //           },
      //           hintText: 'Buscar...',
      //           searchTextEditingController: textController,
      //           horizontalPadding: 5,
      //           searchIconColor: Colors.black,
                
      //         ),
      //     ],
      //   ),
      //   //actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back_ios_new))],
        
       
      // ),
      body: Column(
        children: [

          SizedBox(

            height: h,
            
            width: MediaQuery.of(context).size.width,
            child: Column(
              // Aquí puedes personalizar tu Card según tus necesidades
              children: [
                Card(
                  color: Colors.brown.shade400,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio:
                              16 / 9, // Proporción deseada (puedes ajustarla)
                          child: widget.img != null
                              ? Image.network('${widget.img}',
                                  fit: BoxFit.cover)
                              : Image.network('https://acortar.link/m8RozS',
                                  fit: BoxFit.cover),
                        ),
                        const SizedBox(
                            height: 8), // Espacio entre la imagen y el texto
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
                  dataLength = (snapshot.data as List).length;
                  allAnimals = snapshot.data as List<Map<String, dynamic>>;
                  filteredAnimals =
                      filterAnimals(allAnimals, textController.text);

                  filteredAnimals.sort((a, b) {
                    int compareByProduccion =
                        (b['produccion'] ?? 0).compareTo(a['produccion'] ?? 0);
                    if (compareByProduccion != 0 || compareByProduccion != null) {
                      // Si la comparación por cantidad no es igual, devuelve el resultado de la comparación por cantidad
                      return compareByProduccion;
                    } else {
                      // Si la comparación por cantidad es igual, compara por nombre
                      return a['nombre'].compareTo(b['nombre']);
                    }
                  });
                  return ListView.builder(
                    itemCount: filteredAnimals.length,
                    itemBuilder: (BuildContext context, int index) {
                      // Aquí retornamos una Card antes de un ListTile
                      return Column(
                        children: [
                          Card(
                            // Personaliza tu Card según sea necesario
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
                                await deleteAnimal(filteredAnimals[index]["uid"])
                                    .then((value) {
                                  updateBatchLenght(widget.id, dataLength - 1);
                                  setState(() {
                                    loadData();
                                  });
                                });

                                //snapshot.data?.removeAt(index);
                              },
                              confirmDismiss: (direction) async {
                                bool result = false;

                                result = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Icon(
                                          Icons.warning_amber_rounded),
                                      iconColor: Colors.yellow,
                                      content: Text(
                                        '¿Está seguro de eliminar al animal "${snapshot.data?[index]["nombre"]}"',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            return Navigator.pop(
                                                context, false);
                                          },
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            return Navigator.pop(context, true);
                                          },
                                          child: const Text('Aceptar'),
                                        )
                                      ],
                                    );
                                  },
                                );

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
                                  String? imgAnimal =
                                      filteredAnimals[index]["img"];

                                  String idAnimal =
                                      filteredAnimals[index]["uid"];

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ContentAnimal(
                                            nombre: nombreAnimal,
                                            id: idAnimal,
                                            img: imgAnimal)),
                                  );
                                },
                                title: Text(filteredAnimals[index]["nombre"]),
                                subtitle: Text(filteredAnimals[index]["raza"]),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (String value) async {
                                    if (value == 'Editar') {
                                      // Obtener los datos del lote que se está editando
                                      String nombreLote =
                                          snapshot.data?[index]["nombre"];
                                      int cantidadLote =
                                          snapshot.data?[index]["cantidad"];
                                      String idLote =
                                          snapshot.data?[index]["uid"];

                                      // Abrir la página de edición pasando los argumentos necesarios
                                      /*await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return EditBatch(
                            nombre: nombreLote,
                            cantidad: cantidadLote,
                            id: idLote,
                          );
                        },
                      );*/
                                      setState(() {
                                        // Puedes agregar lógica de actualización aquí si es necesario
                                      });
                                    } else {
                                      //await deleteBatch(snapshot.data?[index]["uid"]);
                                    }
                                  },
                                  color:
                                      const Color.fromARGB(255, 201, 143, 122),
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
        backgroundColor: const Color.fromARGB(255, 201, 143, 122),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddAnimal(
                lote: widget.id,
                finca: widget.finca,
                dataLenght: dataLength,
              );
            },
          ).then((value) {
            setState(() {
              loadData();
            });
          });
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
