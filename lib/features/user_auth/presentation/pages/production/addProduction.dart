import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/service_produccion.dart';

class AddProduction extends StatefulWidget {
  final String animal;
  final double tLitros;
  
  

  const AddProduction({
    Key? key,
    
    required this.animal,
    required this.tLitros,
    
  }) : super(key: key);

  @override
  State<AddProduction> createState() => _AddProductionState();
}

class _AddProductionState extends State<AddProduction> {
  final TextEditingController _cantidadController = TextEditingController(text: '');

  final TextEditingController _fechaController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

 

  @override
  void dispose() {
    _cantidadController.dispose();
    
    _fechaController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  DateTime dateTime = DateTime.now();

  

  
 

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar produccion'),
      content: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  enableSuggestions: true,
                  controller: _cantidadController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad (Lt)',
                    hintText: 'Ingrese la cantidad',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la cantidad';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  
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
                          mode: CupertinoDatePickerMode.date,
                        ),
                      ),
                    );
                  },
                  readOnly: true,
                  controller: _fechaController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Producción',
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la fecha de producción';
                    }
                    return null;
                  },
                ),
                
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Procesando Datos')),
              );
              DateTime fecha = DateTime.parse(_fechaController.text);
               double cantidad = double.parse(_cantidadController.text);

              await addProduccion(
                widget.animal,
                cantidad,
                fecha
              ).then((_) {
                updateAnimalProduccion(widget.animal, widget.tLitros+cantidad);
                Navigator.pop(context);
                
              });
            }
          },
          child: const Text('Guardar'),
        ),
        
      ],
    );
  }
}
