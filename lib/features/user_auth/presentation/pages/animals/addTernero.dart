import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';

// ignore: camel_case_types
class AddTernero extends StatefulWidget {
  const AddTernero({
    Key? key,
  }) : super(key: key);

  @override
  State<AddTernero> createState() => _AddTerneroState();
}

// ignore: camel_case_types
class _AddTerneroState extends State<AddTernero> {
  final TextEditingController _nombreController =
      TextEditingController(text: '');
  final TextEditingController _razaController = TextEditingController(text: '');
  final TextEditingController _fechaController =
      TextEditingController(text: '');

  String? imageUrl;
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

  // Declarar la lista de lotes
  List<Map<String, dynamic>> lotes = [];
  String? selectedLoteUid;

// Función para cargar los lotes
  void cargarLotes() async {
    lotes = await getLotesByUser('');
    // Llamar setState para actualizar la interfaz
    setState(() {});
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se elimina del árbol
    _nombreController.dispose();
    _razaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cargarLotes();
  }

  List<String> razas = [
    'Gyroland F1 (Gyr + Holstein)',
    'Simmbrah F1 (Simmental + Brahman)',
    'Brahamoland F1 (Brahman + Holstein)',
    // Add other breeds here
  ];
  DateTime dateTime = DateTime.now();
  //String _selectedRaza = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: [
            TextField(
              enableSuggestions: true,
              controller: _nombreController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ingrese el nombre del Animal',
              ),
            ),
            DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Raza",
                    hintText: "Selecciona una Raza",
                  ),
                ),
                items: razas,
                selectedItem: _razaController.text, // Set the initial selection
                onChanged: print),
            TextFormField(
              onTap: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => SizedBox(
                    height: 250,
                    child: CupertinoDatePicker(
                      backgroundColor: Colors.white,
                      initialDateTime: dateTime,
                      onDateTimeChanged: (DateTime newTime) {
                        setState(() => dateTime = newTime);
                        _fechaController.text =
                            '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
                      },
                      use24hFormat: true,
                      mode: CupertinoDatePickerMode.date,
                    ),
                  ),
                );
              },
              readOnly: true,
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Nacimiento',
              ),
              keyboardType: TextInputType.datetime,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese la fecha de nacimiento';
                }
                return null;
              },
            ),
            DropdownButton<String>(
              hint: const Text('Seleccione un lote'),
              // Mostrar los nombres de los lotes en el menú desplegable
              items: lotes.map((lote) {
                return DropdownMenuItem<String>(
                  value: lote['uid'],
                  child: Text(lote['nombre']), // Display the lote name
                );
              }).toList(),
              // Manejar el cambio de selección y capturar el UID
              value: selectedLoteUid, // Set the currently selected value
              onChanged: (String? uid) {
                setState(() {
                  selectedLoteUid = uid;
                });
              },
            ),
            IconButton(
              onPressed: _selectImageSource,
              icon: const Icon(Icons.add_photo_alternate),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Cierra el diálogo sin guardar
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime fechaNacimiento =
                        DateTime.parse(_fechaController.text);
                    List<Map<String, dynamic>> fincas = await getFincass();
                    String fincaID = fincas[0]['uid'];
                    await addAnimal(
                            _nombreController.text,
                            _razaController.text,
                            fechaNacimiento,
                            selectedLoteUid!,
                            fincaID,
                            imageUrl,
                            true)
                        .then((_) {
                      Navigator.pop(context); // Cierra el diálogo
                    });
                  },
                  child: const Text('Guardar'),
                ),
              ],
            )
          ]),
    );
  }
}
