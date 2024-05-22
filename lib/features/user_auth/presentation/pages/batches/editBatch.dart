import 'package:flutter/material.dart';
import 'package:moo/services/firebase_service_Batch.dart';

class EditBatch extends StatefulWidget {
  final String nombre;
  final String? img;
  final String id;

  const EditBatch(
      {Key? key, required this.nombre, required this.img, required this.id})
      : super(key: key);

  @override
  State<EditBatch> createState() => _EditBatchState();
}

class _EditBatchState extends State<EditBatch> {
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombre;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.green.shade800,
        title: Text('Editar ${widget.nombre}',style: const TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            widget.img != null
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 200, // Ajusta la altura deseada aquí
                    child: Image.network(widget.img!),
                  )
                :  Image.network('https://acortar.link/twXsOQ'),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                
                labelText: 'Nombre',
                hintText: 'Ingrese el nombre del lote',
              ),
            ),
            const SizedBox(height: 16),
             ElevatedButton(
                onPressed: () async {
                  await updateBatch(widget.id, _nombreController.text)
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
                child: const Text('Actualizar',style: TextStyle(color: Colors.white,fontSize: 20)),
              ),
            
          ],
        ),
      ),
    );
  }
}
