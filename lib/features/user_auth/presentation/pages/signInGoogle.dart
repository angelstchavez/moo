import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:moo/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:moo/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_service_Farm.dart';
import 'package:moo/services/firebase_user.dart';

class AddUserAndFarmGoogle extends StatefulWidget {
  String id;
  String email;

  AddUserAndFarmGoogle({Key? key, required this.email, required this.id})
      : super(key: key);

  @override
  State<AddUserAndFarmGoogle> createState() => _AddUserAndFarmGoogleState();
}

class _AddUserAndFarmGoogleState extends State<AddUserAndFarmGoogle> {
  final TextEditingController _nombreController =
      TextEditingController(text: '');
  final TextEditingController _apellidoController =
      TextEditingController(text: '');
  final TextEditingController _nombreFincaController =
      TextEditingController(text: '');
  final TextEditingController _tamanoFincaController =
      TextEditingController(text: '');

  String? imageUrl;
  bool isSigningUp = false;
  

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _tamanoFincaController.dispose();
    _nombreFincaController.dispose();

    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text(
        'Completar autenticacion con Google',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Container(
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
                controller: _nombreController,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(fontSize: 20),
                  hintText: 'Ingrese el nombre',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 1.0, horizontal: 20),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  floatingLabelStyle:
                      const TextStyle(color: Colors.black, fontSize: 20),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre';
                  }
                  return null;
                },
              ),
              const Gap(10),
              TextFormField(
                style: const TextStyle(fontSize: 20),
                maxLength: 20,
                cursorColor: Colors.black,
                controller: _apellidoController,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Apellido',
                  labelStyle: const TextStyle(fontSize: 20),
                  hintText: 'Ingrese el apellido',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 1.0, horizontal: 20),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  floatingLabelStyle:
                      const TextStyle(color: Colors.black, fontSize: 20),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el apellido';
                  }
                  return null;
                },
              ),
              const Gap(10),
              const Center(
                child: Text('Datos Finca'),
              ),
              const Gap(10),
              TextFormField(
                style: const TextStyle(fontSize: 20),
                maxLength: 20,
                cursorColor: Colors.black,
                controller: _nombreFincaController,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(fontSize: 20),
                  hintText: 'Ingrese la finca',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 1.0, horizontal: 20),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  floatingLabelStyle:
                      const TextStyle(color: Colors.black, fontSize: 20),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la finca';
                  }
                  return null;
                },
              ),
              const Gap(10),
              TextFormField(
                style: const TextStyle(fontSize: 20),
                maxLength: 20,
                cursorColor: Colors.black,
                controller: _tamanoFincaController,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Tamaño',
                  labelStyle: const TextStyle(fontSize: 20),
                  hintText: 'Ingrese el tamaño',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 1.0, horizontal: 20),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  floatingLabelStyle:
                      const TextStyle(color: Colors.black, fontSize: 20),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el tamaño';
                  }
                  return null;
                },
              ),
              const Gap(10),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              crearUser(widget.id);
              crearFinca(widget.id);
              setState(() {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Procesando Datos')),
              );
              
              });
              
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.limeAccent),
          child: const Text(
            'Guardar',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
      ],
      // Evita que se cierre al tocar fuera del AlertDialog
      
    );
  }

  void crearFinca(String userId) async {
    int tamano = int.tryParse(_tamanoFincaController.text) ?? 0;

    // Aquí puedes usar userId para asociar la finca con el usuario
    await addFarm(
      _nombreFincaController.text,
      tamano,
      userId,
    ).then((_){
      setState(() {
        
      });
    });
  }

  void crearUser(String userId) async {
    await addUserP(
      userId,
      userId,
      _nombreController.text,
      _apellidoController.text,
      widget.email,
      null,
    ).then((_) {
      setState(() {
        Navigator.pop(context);
      });
    });
  }
}
