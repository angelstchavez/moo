import 'package:flutter/material.dart';

import 'package:moo/services/firebase_service_Batch.dart';

class EditBatch extends StatefulWidget {
  final String nombre;
  final int cantidad;
  final String id;

  const EditBatch(
      {Key? key,
      required this.nombre,
      required this.cantidad,
      required this.id})
      : super(key: key);

  @override
  State<EditBatch> createState() => _EditBatchState();
}

class _EditBatchState extends State<EditBatch> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar los datos del lote en los controladores al inicializar el estado del widget
    _nombreController.text = widget.nombre;
    _cantidadController.text = widget.cantidad.toString();
  }

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
      title: const Text('Editar Lote'),
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
            await updateBatch(widget.id, _nombreController.text, cantidad)
                .then((_) {
              Navigator.pop(context);
            });
          },
          child: const Text('Actualizar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Cierra el diálogo sin guardar
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
