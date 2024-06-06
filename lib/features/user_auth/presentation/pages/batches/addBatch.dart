import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';

// ignore: camel_case_types
class AddBatch extends StatefulWidget {
  final String fincaId;
  const AddBatch({
    Key? key,
    required this.fincaId,
  }) : super(key: key);

  @override
  State<AddBatch> createState() => _AddBatchState();
}

// ignore: camel_case_types
class _AddBatchState extends State<AddBatch> {
  final TextEditingController _nombreController =
      TextEditingController(text: '');
  final TextEditingController _cantidadController =
      TextEditingController(text: '');

  String? imageUrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se elimina del árbol
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

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
    Reference referenceDireImages = referenceRoot.child('imagesBatch');
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Agregar Lote',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: [
            SizedBox(
              height: imageUrl != null ? 200 : 0,
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                          200.0), // Ajusta el radio según tus necesidades
                      child: Image.network('$imageUrl'),
                    )
                  : null,
            ),
            TextFormField(
              
              style: const TextStyle(fontSize: 20),
              maxLength: 30,
              cursorColor: Colors.black,
              controller: _nombreController,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                  labelText: 'nombre',
                  labelStyle: const TextStyle(fontSize: 20),
                  hintText: 'ingrese el nombre',
                  
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 1.0, horizontal: 20),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  floatingLabelStyle: const TextStyle(color: Colors.black,fontSize: 20),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(100)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(100))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese el nombre';
                }

                return null;
              },
            ),
            /* TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                hintText: 'Ingrese la cantidad del lote',
              ),
              keyboardType: TextInputType.number,
            ), */
            IconButton(
              onPressed: _selectImageSource,
              icon: const Icon(
                Icons.add_photo_alternate,
                size: 35,
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // Cierra el diálogo sin guardar
          },
          child: const Text(
            'Cancelar',
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context); // Cierra el diálogo
              await addBatch(_nombreController.text, widget.fincaId, imageUrl)
                  .then((_) {});
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.limeAccent),
          child: const Text(
            'Guardar',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ],
    );
  }
}
