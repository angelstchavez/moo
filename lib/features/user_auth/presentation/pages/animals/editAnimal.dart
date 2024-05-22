import 'package:flutter/material.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';

class EditAnimal extends StatefulWidget {
  final String nombre;
  final String? img;
  final String id;
  final bool parto;

  const EditAnimal(
      {Key? key,
      required this.nombre,
      required this.img,
      required this.id,
      required this.parto})
      : super(key: key);

  @override
  State<EditAnimal> createState() => _EditAnimalState();
}

class _EditAnimalState extends State<EditAnimal> {
  final TextEditingController _nombreController = TextEditingController();
  late bool parto; // Declara parto como una variable de instancia

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombre;
    parto =
        widget.parto; // Inicializa parto con el valor pasado desde el widget
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
                : Image.network('https://acortar.link/twXsOQ'),
            const SizedBox(height: 16),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ingrese el nombre del lote',
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Text(
                    ' Parto',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(), // Espaciado flexible para empujar el switch hacia la derecha
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    value: parto,
                    onChanged: (value) async {
                      setState(() {
                        parto = value; // Actualiza el valor de parto
                        updateAnimalParto(widget.id, parto);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await updateAnimal(widget.id, _nombreController.text).then((_) {
                  Navigator.pop(context, true);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Bordes redondeados
                ),
              ),
              child: const Text('Actualizar',
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
