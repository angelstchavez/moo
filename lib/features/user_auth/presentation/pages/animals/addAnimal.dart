import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';

// ignore: camel_case_types
class AddAnimal extends StatefulWidget {

  final String lote;
  final String finca;
  const AddAnimal({Key? key,
      required this.finca,
      required this.lote
      })
      : super(key: key);

  @override
  State<AddAnimal> createState() => _AddAnimalState();
}

// ignore: camel_case_types
class _AddAnimalState extends State<AddAnimal> {
  final TextEditingController _nombreController = TextEditingController(text: '');
  final TextEditingController _razaController = TextEditingController(text: '');
  final TextEditingController _fechaController = TextEditingController(text: '');    

  

  

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se elimina del árbol
    _nombreController.dispose();
    _razaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

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
          TextField(
            controller: _razaController,
            decoration: const InputDecoration(
              labelText: 'Raza',
              hintText: 'Ingrese la Raza del animal',
            ),
            keyboardType: TextInputType.name,
          ),
          TextField(
            
            controller: _fechaController,
            decoration: const InputDecoration(

              labelText: 'Fecha de Nacimiento',
              
            ),
            keyboardType: TextInputType.datetime,
          ),
          
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            
            
            DateTime fechaNacimiento = DateTime.parse(_fechaController.text);

            await addAnimal(_nombreController.text,_razaController.text,fechaNacimiento,widget.lote,widget.finca).then((_) {
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