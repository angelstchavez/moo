import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';

// ignore: camel_case_types
class AddAnimal extends StatefulWidget {
  final String lote;
  final String finca;
  final int dataLenght;
  const AddAnimal(
      {Key? key,
      required this.finca,
      required this.lote,
      required this.dataLenght})
      : super(key: key);

  @override
  State<AddAnimal> createState() => _AddAnimalState();
}

// ignore: camel_case_types
class _AddAnimalState extends State<AddAnimal> {
  final TextEditingController _nombreController =
      TextEditingController(text: '');
  final TextEditingController _razaController = TextEditingController(text: '');
  final TextEditingController _fechaController =
      TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

  String? imageUrl;

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se elimina del árbol
    _nombreController.dispose();
    _razaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  DateTime dateTime = DateTime.now();
  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Animal'),
      content: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
              maxWidth: 400), // Establece el tamaño máximo del formulario
          padding: EdgeInsets.all(16), // Añade relleno para mejor apariencia
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  enableSuggestions: true,
                  controller: _nombreController,
                  autofocus: true,
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
                TextFormField(
                  controller: _razaController,
                  decoration: const InputDecoration(
                    labelText: 'Raza',
                    hintText: 'Ingrese la Raza del animal',
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la raza del animal';
                    }
                    return null;
                  },
                ),
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
                                 _fechaController.text = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';

                                },

                                use24hFormat: true,
                                mode: CupertinoDatePickerMode.date
                              ),
                              
                            )
                            
                            
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
                    // Aquí podrías agregar una validación adicional si es necesario
                    return null;
                  },
                ),
                IconButton(
                    onPressed: () async {
                      final file = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      if (file == null) return;

                      String fileName =
                          DateTime.now().microsecondsSinceEpoch.toString();

                      //creamos el folder en firebase storage
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDireImages =
                          referenceRoot.child('images');

                      Reference referenceImageUpload =
                          referenceDireImages.child(fileName);

                      try {
                        await referenceImageUpload.putFile(File(file.path));

                        imageUrl = await referenceImageUpload.getDownloadURL();
                      } catch (e) {
                        // Manejo de errores
                      }
                    },
                    icon: const Icon(Icons.add_photo_alternate))
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Si el formulario es válido, procesa los datos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
              DateTime fechaNacimiento = DateTime.parse(_fechaController.text);

              await addAnimal(_nombreController.text, _razaController.text,
                      fechaNacimiento, widget.lote, widget.finca, imageUrl)
                  .then((_) {
                Navigator.pop(context);

                updateBatchLenght(
                    widget.lote, widget.dataLenght + 1); // Cierra el diálogo
              });
            }
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
