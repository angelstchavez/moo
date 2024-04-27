import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se elimina del árbol
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Lote'),
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
              hintText: 'Ingrese el nombre del lote',
            ),
          ),
          TextField(
            controller: _cantidadController,
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              hintText: 'Ingrese la cantidad del lote',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            int cantidad = int.tryParse(_cantidadController.text) ?? 0;
            List<Map<String, dynamic>> fincas = await getFincas();
            String fincaID = fincas[0]['uid'];

            await addBatch(_nombreController.text, cantidad,fincaID).then((_) {
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
