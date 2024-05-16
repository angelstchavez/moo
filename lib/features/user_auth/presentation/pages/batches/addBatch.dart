import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';

// ignore: camel_case_types
class AddBatch extends StatefulWidget {
  const AddBatch({Key? key}) : super(key: key);

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
                leading:const Icon(Icons.photo),
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
      title: const Text('Agregar Lote'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: [
          TextFormField(
            enableSuggestions: true,
            controller: _nombreController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ingrese el nombre del lote',
            ),
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
                  icon: const Icon(Icons.add_photo_alternate),
                ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            
            List<Map<String, dynamic>> fincas = await getFincas();
            String fincaID = fincas[0]['uid'];

            await addBatch(_nombreController.text,fincaID,imageUrl).then((_) {
              
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
