import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/addTernero.dart';
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

  const EditAnimal(
      {Key? key,
      required this.finca,
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

    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

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
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 200, // Ajusta la altura deseada aquí
                      child: Image.network(widget.img!),
                    )
                  : Image.network('https://acortar.link/twXsOQ'),
              const Gap(16),
              Card(
                child: Column(
                  children: [
                    const Text('Datos Vaca'),
                    const Gap(16),
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ingrese el nombre del animal',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el nombre del animal';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Edad: $edad',
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () async {
                        await updateAnimal(widget.id, _nombreController.text)
                            .then((_) {
                          Navigator.pop(context, true);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Bordes redondeados
                        ),
                      ),
                      child: const Text('Actualizar',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                    const Gap(16)
                  ],
                ),
              ),
              const Gap(16),
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Row(
              //     children: [
                    // const Text(
                    //   ' Parto',
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 16,
                    //   ),
                    // ),
                    // const Spacer(), // Espaciado flexible para empujar el switch hacia la derecha
                    // Switch(
                    //   activeColor: Colors.white,
                    //   activeTrackColor: Colors.green,
                    //   inactiveThumbColor: Colors.white,
                    //   inactiveTrackColor: Colors.grey,
                    //   value: parto,
                    //   onChanged: (value) async {
                    //     setState(() {
                    //       parto = value; // Actualiza el valor de parto
                    //       updateAnimalParto(widget.id, parto,false,);
                    //       Fluttertoast.showToast(
                                          
                    //                       msg: 'Parto Exitoso...',
                    //                       backgroundColor: Colors.green,
                    //                       webPosition: 'left',
                    //                       fontSize: 20,
                                           

                                        
                    //                     );
                    //     });
                    //   },
                    // ),
              //     ],
              //   ),
              // ),
              // const Gap(16),
              parto == false
                  ? ExpansionTile(
                      title: const Text('Agregar Parto'),
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 400),
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: imageUrl != null ? 200 : 0,
                                    child: imageUrl != null
                                        ? Image.network('$imageUrl')
                                        : null,
                                  ),
                                  TextFormField(
                                    enableSuggestions: true,
                                    controller: _nombreTerneroController,
                                    autofocus: false,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre',
                                      hintText: 'Ingrese el nombre del Animal',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, ingrese el nombre del animal';
                                      }
                                      return null;
                                    },
                                  ),
                                  DropdownSearch<String>(
                                    dropdownDecoratorProps:
                                        const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
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
                                  DropdownSearch<String>(
                                    dropdownDecoratorProps:
                                        const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Sexo",
                                        hintText: "Seleccione el sexo",
                                      ),
                                    ),
                                    items: sexo,
                                    selectedItem: _sexoTerneroController
                                        .text, // Set the initial selection
                                    onChanged: (String? selectedSexo) {
                                      setState(() {
                                        _sexoTerneroController.text =
                                            selectedSexo ??
                                                ''; // Update the controller value
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El sexo es obligatorio!';
                                      }
                                      return null;
                                    },
                                  ),
                                  IconButton(
                                    onPressed: _selectImageSource,
                                    icon: const Icon(Icons.add_photo_alternate),
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
                                        await updateAnimalParto(widget.id, true,true,).then((_){
                                          setState(() {
                                            parto=true;
                                          });
                                        });

                                        Fluttertoast.showToast(
                                          backgroundColor: Colors.green,
                                          
                                          msg: 'Parto Exitoso...',

                                        
                                        );
                                        
                                      }
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
                                            color: Colors.white, fontSize: 20)),
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
