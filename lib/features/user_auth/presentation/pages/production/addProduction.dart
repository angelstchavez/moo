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
  final TextEditingController _cantidadController =
      TextEditingController(text: '');

  final TextEditingController _fechaController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

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
      title: const Text(
        'Agregar Producción',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  style: const TextStyle(fontSize: 20),
                  maxLength: 20,
                  cursorColor: Colors.black,
                  controller: _cantidadController,
                  decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Cantidad(lt)',
                      labelStyle: const TextStyle(fontSize: 20),
                      hintText: 'ingrese la cantidad',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 20),
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      floatingLabelStyle:
                          const TextStyle(color: Colors.black, fontSize: 20),
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(100)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(100))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese la cantidad';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        DateTime currentDate = DateTime.now();
                        DateTime initialDate = DateTime(currentDate.year,
                            currentDate.month, currentDate.day);
                        DateTime minDate = DateTime(currentDate.year,
                            currentDate.month, currentDate.day);
                        DateTime maxDate = DateTime(currentDate.year,
                            currentDate.month, currentDate.day);

                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => SizedBox(
                            height: 250,
                            child: CupertinoDatePicker(
                              backgroundColor: Colors.white,
                              initialDateTime: initialDate,
                              maximumDate: maxDate,
                              onDateTimeChanged: (DateTime newTime) {
                                setState(() {
                                  dateTime = newTime;
                                  _fechaController.text =
                                      DateFormat('yyyy-MM-dd').format(newTime);
                                });
                              },
                              use24hFormat: true,
                              mode: CupertinoDatePickerMode.date,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 1.0, horizontal: 20),
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    floatingLabelStyle: const TextStyle(color: Colors.black),
                    hintStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(100)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.green),
                        borderRadius: BorderRadius.circular(100)),
                    labelText: "Fecha de producción",
                  ),
                  readOnly: true,
                  controller: _fechaController,
                  keyboardType: TextInputType.datetime,
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
          child: const Text(
            'Cancelar',
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Procesando Datos')),
              );
              DateTime fecha = DateTime.parse(_fechaController.text);
              double cantidad = double.parse(_cantidadController.text);

              await addProduccion(widget.animal, cantidad, fecha).then((_) {
                updateAnimalProduccion(
                    widget.animal, widget.tLitros + cantidad);
                Navigator.pop(context);
              });
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
