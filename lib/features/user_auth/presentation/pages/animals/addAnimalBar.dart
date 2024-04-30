import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';

// ignore: camel_case_types
class AddAnimalBar extends StatefulWidget {
  const AddAnimalBar({
    Key? key,
  }) : super(key: key);

  @override
  State<AddAnimalBar> createState() => _AddAnimalBarState();
}

// ignore: camel_case_types
class _AddAnimalBarState extends State<AddAnimalBar> {
  final TextEditingController _nombreController =
      TextEditingController(text: '');
  final TextEditingController _razaController = TextEditingController(text: '');
  final TextEditingController _fechaController =
      TextEditingController(text: '');

  String imageUrl = '';

  // Declarar la lista de lotes
  List<Map<String, dynamic>> lotes = [];
  String? selectedLoteUid;

// Función para cargar los lotes
  void cargarLotes() async {
    lotes = await getLotesByUser();
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
  String _selectedRaza = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Animal'),
      content: Column(
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
              onChanged:print
            ),
            TextField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Nacimiento',
              ),
              keyboardType: TextInputType.datetime,
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
                onPressed: () async {
                  final file =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (file == null) return;

                  String fileName =
                      DateTime.now().microsecondsSinceEpoch.toString();

                  //creamos el folder en firebase storage
                  Reference referenceRoot = FirebaseStorage.instance.ref();
                  Reference referenceDireImages = referenceRoot.child('images');

                  Reference referenceImageUpload =
                      referenceDireImages.child(fileName);

                  try {
                    await referenceImageUpload.putFile(File(file.path));

                    imageUrl = await referenceImageUpload.getDownloadURL();
                  } catch (e) {
                    //some
                  }
                },
                icon: const Icon(Icons.add_photo_alternate))
          ]),
      actions: [
        ElevatedButton(
          onPressed: () async {
            DateTime fechaNacimiento = DateTime.parse(_fechaController.text);
            List<Map<String, dynamic>> fincas = await getFincas();
            String fincaID = fincas[0]['uid'];
            await addAnimal(_nombreController.text, _razaController.text,
                    fechaNacimiento, selectedLoteUid!, fincaID, imageUrl)
                .then((_) {
              Navigator.pop(context); // Cierra el diálogo
            });
          },
          child: const Text('Guardar'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // Cierra el diálogo sin guardar
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
