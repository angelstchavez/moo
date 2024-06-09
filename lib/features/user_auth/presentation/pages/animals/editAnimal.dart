import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/addTernero.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/contentAnimal.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/addBatch.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';

class EditAnimal extends StatefulWidget {
  final String nombre;
  final String? img;
  final String id;
  final bool parto;
  final String fechaN;
  final String finca;
  final String raza;

  const EditAnimal(
      {Key? key,
      required this.finca,
      required this.raza,
      required this.nombre,
      required this.fechaN,
      required this.img,
      required this.id,
      required this.parto})
      : super(key: key);

  @override
  State<EditAnimal> createState() => _EditAnimalState();
}

class _EditAnimalState extends State<EditAnimal> {
  late bool parto; // Declara parto como una variable de instancia
  late int years;
  late String edad; // Variable para almacenar los años calculados

  final TextEditingController _nombreController =
      TextEditingController(text: '');
  final TextEditingController _razaController = TextEditingController(text: '');
  final TextEditingController _nombreTerneroController =
      TextEditingController(text: '');
  final TextEditingController _razaTerneroController =
      TextEditingController(text: '');
  final TextEditingController _sexoTerneroController =
      TextEditingController(text: '');
  final TextEditingController _fechaTerneroController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day)));

  String? imageUrl;

  @override
  void dispose() {
    _nombreController.dispose();
    _razaTerneroController.dispose();

    textController.addListener(() {
      setState(() {
        filteredCrias = filterCrias(allCrias, textController.text);
      });
    });
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> allCrias = [];
  List<Map<String, dynamic>> filteredCrias = [];
  final currentUser = FirebaseAuth.instance.currentUser!;
  int dataLength = 0;

  List<Map<String, dynamic>> filterCrias(
      List<Map<String, dynamic>> animals, String searchText) {
    return animals.where((animal) {
      final animalName = animal['nombre'].toString().toLowerCase();
      final searchLower = searchText.toLowerCase();
      return animalName.contains(searchLower);
    }).toList();
  }

  // Método para cargar los datos

  DateTime dateTime = DateTime.now();

  void _selectImageSource() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () async {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Galería'),
                onTap: () async {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    String fileName = DateTime.now().microsecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDireImages = referenceRoot.child('images');
    Reference referenceImageUpload = referenceDireImages.child(fileName);

    try {
      await referenceImageUpload.putFile(File(pickedFile.path));
      String downloadUrl = await referenceImageUpload.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
    } catch (e) {
      // Manejo de errores
    }
  }

  List<String> razas = [
    'Gyroland F1 (Gyr + Holstein)',
    'Simmbrah F1 (Simmental + Brahman)',
    'Brahamoland F1 (Brahman + Holstein)',
    // Add other breeds here
  ];

  List<String> sexo = [
    'Macho',
    'Hembra',

    // Add other breeds here
  ];

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombre;
    _razaController.text = widget.raza;
    parto =
        widget.parto; // Inicializa parto con el valor pasado desde el widget

    // Calcula la edad a partir de la fecha de nacimiento
    DateTime birthDate = DateFormat("yyyy-MM-dd").parse(widget.fechaN);
    String age = calculateAge(birthDate);
    edad = age;
  }

  String calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    years = today.year - birthDate.year; // Almacena los años calculados
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (days < 0) {
      final prevMonth = DateTime(today.year, today.month - 1, birthDate.day);
      days = today.difference(prevMonth).inDays;
      months -= 1;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return "$years años, $months meses y $days días";
  }

  @override
  Widget build(BuildContext context) {
    // Definir la lista de íconos, nombres y colores
    List<Map<String, dynamic>> gridItems = [
      {'icon': Icons.info, 'label': 'Info', 'color': Colors.green},
      {
        'icon': Icons.child_friendly_rounded,
        'label': 'Crias',
        'color': Colors.blue
      },
      // {'icon': Icons.vaccines, 'label': 'Vacuna', 'color': Colors.orange},
      // {'icon': Icons.health_and_safety, 'label': 'Salud', 'color': Colors.red},
      // Agrega más ítems según sea necesario
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade800,
        title: Text('Editar ${widget.nombre}',
            style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              widget.img != null
                  ? CircleAvatar(
                      radius: 100, // Ajusta la altura deseada aquí
                      backgroundImage: NetworkImage(widget.img!),
                    )
                  : const CircleAvatar(
                      radius: 100, // Ajusta la altura deseada aquí
                      backgroundImage:
                          NetworkImage('https://acortar.link/hrux2P'),
                    ),
              const Gap(16),
              Card(
                child: Column(
                  children: [
                    const Text(
                      'Datos Animal',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    const Gap(16),
                    // GridView agregado aquí
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: gridItems.length,
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                          onPressed: () async {
                            // Acciones al presionar el botón
                            if (gridItems[index]['label'] == 'Info') {
                              if (widget.parto == true ||
                                  widget.parto == false) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      padding: const EdgeInsets.all(16.0),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Información de ${widget.nombre}',
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 10),
                                            TextFormField(
                                              controller: _nombreController,
                                              decoration: InputDecoration(
                                                  labelText: 'nombre',
                                                  hintText: 'ingrese el nombre',
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 1.0,
                                                          horizontal: 20),
                                                  filled: true,
                                                  fillColor:
                                                      Colors.grey.shade300,
                                                  floatingLabelStyle:
                                                      const TextStyle(
                                                          color: Colors.black),
                                                  hintStyle: const TextStyle(
                                                      color: Colors.black),
                                                  border: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color: Colors.green),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderSide: const BorderSide(
                                                          color: Colors.green),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100))),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Por favor, ingrese el nombre';
                                                }
                                                if (value.length > 15) {
                                                  return 'El nombre permite maximo 15 dígitos';
                                                }

                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            DropdownSearch<String>(
                                              dropdownDecoratorProps:
                                                  DropDownDecoratorProps(
                                                dropdownSearchDecoration:
                                                    InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 1.0,
                                                          horizontal: 20),
                                                  filled: true,
                                                  fillColor:
                                                      Colors.grey.shade300,
                                                  floatingLabelStyle:
                                                      const TextStyle(
                                                          color: Colors.black),
                                                  hintStyle: const TextStyle(
                                                      color: Colors.black),
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.green),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100)),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .green),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100)),
                                                  labelText: "Raza",
                                                  hintText:
                                                      "Selecciona una Raza",
                                                ),
                                              ),
                                              items: razas,
                                              selectedItem: _razaController
                                                  .text, // Set the initial selection
                                              onChanged:
                                                  (String? selectedRaza) {
                                                setState(() {
                                                  _razaController.text =
                                                      selectedRaza ??
                                                          ''; // Update the controller value
                                                });
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'La raza es obligatoria!';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            const Gap(16),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  await updateAnimal(
                                                      widget.id,
                                                      _nombreController.text,
                                                      _razaController.text);
                                                  setState(() {
                                                    print(_razaController.text);
                                                  });
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30), // Bordes redondeados
                                                ),
                                              ),
                                              child: const Text('Actualizar',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                            if (gridItems[index]['label'] == 'Crias' &&
                                widget.parto) {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Crias',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        const Gap(16),
                                        Expanded(
                                          child: FutureBuilder(
                                            future:
                                                getTernerosByVaca(widget.id),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.green,
                                                    backgroundColor:
                                                        Colors.blueAccent,
                                                    strokeWidth: 5,
                                                  ),
                                                );
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'),
                                                );
                                              } else if (snapshot.data ==
                                                      null ||
                                                  (snapshot.data as List)
                                                      .isEmpty) {
                                                return Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      IconButton(
                                                        onPressed: () async {
                                                          // await showDialog(
                                                          //   context: context,
                                                          //   builder:
                                                          //       (BuildContext
                                                          //           context) {
                                                          //     return const AddBatch();
                                                          //   },
                                                          // );
                                                          // setState(() {});
                                                        },
                                                        icon: const Icon(
                                                            Icons.add),
                                                        iconSize: 70,
                                                        color: Colors.grey,
                                                      ),
                                                      const Text(
                                                        'No se encontraron datos',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                dataLength =
                                                    (snapshot.data as List)
                                                        .length;
                                                allCrias = snapshot.data
                                                    as List<
                                                        Map<String, dynamic>>;
                                                filteredCrias = filterCrias(
                                                    allCrias,
                                                    textController.text);

                                                filteredCrias.sort((a, b) {
                                                  int compareByProduccion =
                                                      (b['produccion'] ?? 0)
                                                          .compareTo(
                                                              a['produccion'] ??
                                                                  0);
                                                  if (compareByProduccion !=
                                                      0) {
                                                    return compareByProduccion;
                                                  } else {
                                                    return a['nombre']
                                                        .compareTo(b['nombre']);
                                                  }
                                                });
                                                return ListView.builder(
                                                  itemCount:
                                                      filteredCrias.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    final animal =
                                                        filteredCrias[index];
                                                    return Column(
                                                      children: [
                                                        Card(
                                                          child: Dismissible(
                                                            background:
                                                                Container(
                                                              color:
                                                                  Colors.blue,
                                                              alignment:
                                                                  AlignmentDirectional
                                                                      .centerStart,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 15),
                                                              child: const Icon(
                                                                Icons
                                                                    .edit_square,
                                                                color: Colors
                                                                    .white,
                                                                size: 25,
                                                              ),
                                                            ),
                                                            secondaryBackground:
                                                                Container(
                                                              color: Colors.red,
                                                              alignment:
                                                                  AlignmentDirectional
                                                                      .centerEnd,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          15),
                                                              child: const Icon(
                                                                Icons
                                                                    .delete_forever,
                                                                color: Colors
                                                                    .white,
                                                                size: 30,
                                                              ),
                                                            ),
                                                            direction: currentUser
                                                                        .displayName !=
                                                                    'trabajador'
                                                                ? DismissDirection
                                                                    .horizontal
                                                                : DismissDirection
                                                                    .startToEnd,
                                                            onDismissed:
                                                                (direction) async {
                                                              if (direction ==
                                                                  DismissDirection
                                                                      .startToEnd) {
                                                                // Manejo de la edición
                                                              }
                                                            },
                                                            confirmDismiss:
                                                                (direction) async {
                                                              bool result =
                                                                  false;
                                                              String
                                                                  nombreAnimal =
                                                                  animal[
                                                                      'nombre'];
                                                              String
                                                                  razaAnimal =
                                                                  animal[
                                                                      'raza'];
                                                              bool partoAnimal =
                                                                  animal[
                                                                      'esMadre'];
                                                              String?
                                                                  imgAnimal =
                                                                  animal['img'];
                                                              String idAnimal =
                                                                  animal['uid']
                                                                      .toString();
                                                              String
                                                                  fechaAnimal =
                                                                  animal[
                                                                      'fecha'];
                                                              String finca =
                                                                  animal[
                                                                      'finca'];

                                                              if (direction ==
                                                                  DismissDirection
                                                                      .startToEnd) {
                                                                result = false;
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              EditAnimal(
                                                                                raza: razaAnimal,
                                                                                fechaN: fechaAnimal,
                                                                                nombre: nombreAnimal,
                                                                                id: idAnimal,
                                                                                img: imgAnimal,
                                                                                parto: partoAnimal,
                                                                                finca: finca,
                                                                              )),
                                                                ).then((value) =>
                                                                    setState(
                                                                        () {}));
                                                              } else {
                                                                result =
                                                                    await showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      title:
                                                                          const Icon(
                                                                        Icons
                                                                            .question_mark_rounded,
                                                                        size:
                                                                            50,
                                                                        color: Colors
                                                                            .blue,
                                                                      ),
                                                                      iconColor:
                                                                          Colors
                                                                              .red,
                                                                      content:
                                                                          Text(
                                                                        '¿Está seguro de eliminar a $nombreAnimal?',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                20),
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context,
                                                                                false);
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            'Cancelar',
                                                                            style:
                                                                                TextStyle(color: Colors.red, fontSize: 20),
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () async {
                                                                            await deleteAnimal(idAnimal).then(
                                                                              (value) {
                                                                                setState(() {});
                                                                              },
                                                                            );
                                                                            showToast(message: 'Animal eliminado exitosamente');
                                                                            Navigator.pop(context,
                                                                                true);
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            'Aceptar',
                                                                            style:
                                                                                TextStyle(color: Colors.green, fontSize: 20),
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
                                                            key: Key(
                                                                filteredCrias[
                                                                        index]
                                                                    ["uid"]),
                                                            child: ListTile(
                                                              leading: CircleAvatar(
                                                                  radius: 27,
                                                                  backgroundImage: filteredCrias[index]
                                                                              [
                                                                              'img'] ==
                                                                          null
                                                                      ? const NetworkImage(
                                                                          'https://acortar.link/hrux2P')
                                                                      : NetworkImage(
                                                                          '${filteredCrias[index]['img']}')),
                                                              onTap: () async {
                                                                String
                                                                    nombreAnimal =
                                                                    filteredCrias[
                                                                            index]
                                                                        [
                                                                        "nombre"];
                                                                String
                                                                    razaAnimal =
                                                                    filteredCrias[
                                                                            index]
                                                                        [
                                                                        "raza"];
                                                                String?
                                                                    imgAnimal =
                                                                    filteredCrias[
                                                                            index]
                                                                        ["img"];
                                                                String
                                                                    idAnimal =
                                                                    filteredCrias[
                                                                            index]
                                                                        ["uid"];
                                                                String
                                                                    fechaAnimal =
                                                                    filteredCrias[
                                                                            index]
                                                                        [
                                                                        "fecha"];
                                                                bool parto =
                                                                    filteredCrias[
                                                                            index]
                                                                        [
                                                                        "parto"];
                                                                int edadTernero =
                                                                    filteredCrias[
                                                                            index]
                                                                        [
                                                                        "edadTernero"];
                                                                String finca =
                                                                    filteredCrias[
                                                                            index]
                                                                        [
                                                                        'finca'];

                                                                if (parto) {
                                                                  if (edadTernero <
                                                                      1) {
                                                                    Navigator
                                                                        .push(
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
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return AlertDialog(
                                                                        title:
                                                                            const Icon(
                                                                          Icons
                                                                              .info,
                                                                          size:
                                                                              50,
                                                                          color:
                                                                              Colors.amber,
                                                                        ),
                                                                        iconColor:
                                                                            Colors.yellow,
                                                                        content:
                                                                            Text(
                                                                          'No puedes agregarle produccion a la vaca $nombreAnimal porque no tiene un parto, ve a a editar y agrega un parto',
                                                                          style:
                                                                              const TextStyle(fontSize: 20),
                                                                        ),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                    builder: (context) => EditAnimal(
                                                                                          raza: razaAnimal,
                                                                                          fechaN: fechaAnimal,
                                                                                          nombre: nombreAnimal,
                                                                                          id: idAnimal,
                                                                                          img: imgAnimal,
                                                                                          parto: parto,
                                                                                          finca: finca,
                                                                                        )),
                                                                              ).then((value) => setState(() {
                                                                                    Navigator.pop(context);
                                                                                  }));
                                                                            },
                                                                            child:
                                                                                const Text(
                                                                              'OK',
                                                                              style: TextStyle(color: Colors.blue, fontSize: 20),
                                                                            ),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text(
                                                                              'Cancelar',
                                                                              style: TextStyle(color: Colors.red, fontSize: 20),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              title: Text(
                                                                  filteredCrias[
                                                                          index]
                                                                      [
                                                                      "nombre"]),
                                                              subtitle: Text(
                                                                  filteredCrias[
                                                                          index]
                                                                      ["raza"]),
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
                                  );
                                },
                              );
                            } else {
                              if (gridItems[index]['label'] == 'Crias' &&
                                  widget.parto == false) {
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
                                        'La vaca ${widget.nombre} no tiene crias!',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'OK',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 20),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            iconColor: Colors.black,
                            backgroundColor: Colors.lightGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(gridItems[index]['icon'],
                                  size: 50, color: Colors.grey),
                              const SizedBox(height: 10),
                              Text(gridItems[index]['label'],
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        );
                      },
                    ),

                    const Gap(16),
                  ],
                ),
              ),
              const Gap(16),
              parto == false
                  ? ExpansionTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.green.shade50),
                        child: const Icon(
                          Icons.add,
                          color: Colors.lime,
                        ),
                      ),
                      title: const Text('Agregar Parto'),
                      iconColor: Colors.green,
                      backgroundColor: Colors.grey.shade100,
                      collapsedIconColor: Colors.black,
                      expansionAnimationStyle: AnimationStyle(
                          curve: Curves.easeInCirc,
                          duration: Durations.extralong1),
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  imageUrl != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage('$imageUrl'),
                                          radius: 60,
                                        )
                                      : const CircleAvatar(
                                          radius: 0,
                                        ),
                                  const Gap(15),
                                  TextFormField(
                                    autofocus: true,
                                    style: const TextStyle(fontSize: 20),
                                    maxLength: 20,
                                    cursorColor: Colors.black,
                                    controller: _nombreTerneroController,
                                    decoration: InputDecoration(
                                        alignLabelWithHint: true,
                                        labelText: 'nombre',
                                        labelStyle:
                                            const TextStyle(fontSize: 20),
                                        hintText: 'ingrese el nombre',
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 1.0, horizontal: 20),
                                        filled: true,
                                        fillColor: Colors.grey.shade300,
                                        floatingLabelStyle: const TextStyle(
                                            color: Colors.black, fontSize: 20),
                                        hintStyle:
                                            const TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.green),
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.green),
                                            borderRadius:
                                                BorderRadius.circular(100))),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, ingrese el nombre';
                                      }

                                      return null;
                                    },
                                  ),
                                  const Gap(10),
                                  DropdownSearch<String>(
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 1.0, horizontal: 20),
                                        filled: true,
                                        fillColor: Colors.grey.shade300,
                                        floatingLabelStyle: const TextStyle(
                                            color: Colors.black),
                                        hintStyle: const TextStyle(
                                            color: Colors.black),
                                        border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.green),
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.green),
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        labelText: "Raza",
                                        hintText: "Selecciona una Raza",
                                      ),
                                    ),
                                    items: razas,
                                    selectedItem: _razaTerneroController
                                        .text, // Set the initial selection
                                    onChanged: (String? selectedRaza) {
                                      setState(() {
                                        _razaTerneroController.text =
                                            selectedRaza ??
                                                ''; // Update the controller value
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'La raza es obligatoria!';
                                      }
                                      return null;
                                    },
                                  ),
                                  const Gap(10),
                                  DropdownSearch<String>(
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 1.0, horizontal: 20),
                                        filled: true,
                                        fillColor: Colors.grey.shade300,
                                        floatingLabelStyle: const TextStyle(
                                            color: Colors.black),
                                        hintStyle: const TextStyle(
                                            color: Colors.black),
                                        border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.green),
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.green),
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        labelText: "Sexo",
                                        hintText: "Selecciona un sexo",
                                      ),
                                    ),
                                    items: sexo,
                                    selectedItem: _sexoTerneroController
                                        .text, // Set the initial selection
                                    onChanged: (String? selectedSexo) {
                                      setState(() {
                                        _razaTerneroController.text =
                                            selectedSexo ??
                                                ''; // Update the controller value
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El sexo es obligatoria!';
                                      }
                                      return null;
                                    },
                                  ),
                                  IconButton(
                                    onPressed: _selectImageSource,
                                    icon: const Icon(
                                      Icons.add_photo_alternate,
                                      size: 35,
                                    ),
                                  ),
                                  const Gap(20),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await addTernero(
                                                _nombreTerneroController.text,
                                                _razaTerneroController.text,
                                                widget.finca,
                                                imageUrl,
                                                widget.id)
                                            .then((_) {
                                          setState(() {
                                            _nombreTerneroController.clear();
                                            _razaTerneroController.clear();
                                            _sexoTerneroController.clear();
                                            imageUrl = null;
                                          });
                                        });
                                        await updateAnimalParto(
                                          widget.id,
                                          true,
                                          true,
                                        ).then((_) {
                                          setState(() {
                                            parto = true;
                                          });
                                        });

                                        Fluttertoast.showToast(
                                          backgroundColor: Colors.green,
                                          msg: 'Parto Exitoso...',
                                        );
                                      }
                                      setState(() {});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            30), // Bordes redondeados
                                      ),
                                    ),
                                    child: const Text('Guardar',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 17)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Text(''),
            ],
          ),
        ),
      ),
    );
  }
}
