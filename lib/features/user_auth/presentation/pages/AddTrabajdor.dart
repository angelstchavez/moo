import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moo/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:moo/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Animal.dart';
import 'package:moo/services/firebase_service_Batch.dart';
import 'package:moo/services/firebase_user.dart';

class AddTrabajador extends StatefulWidget {
  final String jefe;
  final String finca;

  const AddTrabajador({
    Key? key,
    required this.finca,
    required this.jefe,
  }) : super(key: key);

  @override
  State<AddTrabajador> createState() => _AddTrabajadorState();
}

class _AddTrabajadorState extends State<AddTrabajador> {
  final TextEditingController _nombreController =
      TextEditingController(text: '');
  final TextEditingController _apellidoController =
      TextEditingController(text: '');
  final TextEditingController _sexoController = TextEditingController(text: '');
  final TextEditingController _emailController =
      TextEditingController(text: '');
  final TextEditingController _rolController = TextEditingController(text: '');
  final TextEditingController _telefonoController =
      TextEditingController(text: '');
  final TextEditingController _fechaController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime(
          DateTime.now().year - 3, DateTime.now().month, DateTime.now().day)));

  String? imageUrl;
  bool isSigningUp = false;
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    _nombreController.dispose();
    _sexoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  DateTime dateTime = DateTime.now();

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
    Reference referenceDireImages = referenceRoot.child('imagesUsers');
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

  List<String> sexo = [
    'Masculino',
    'Femenino',

    // Add other breeds here
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Agregar Trabajador'),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                enableSuggestions: true,
                controller: _nombreController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ingrese el nombre del trabajador',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del trabajador';
                  }
                  return null;
                },
              ),
              TextFormField(
                enableSuggestions: true,
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  hintText: 'Ingrese el apelido del trabajador',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el apellido del trabajador';
                  }
                  return null;
                },
              ),
              DropdownSearch<String>(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "sexo",
                    hintText: "Seleccione un sexo",
                  ),
                ),
                items: sexo,
                selectedItem: _sexoController.text, // Set the initial selection
                onChanged: (String? selectedSexo) {
                  setState(() {
                    _sexoController.text =
                        selectedSexo ?? ''; // Update the controller value
                  });
                },
                validator:(value) {
                  if (value == null || value.isEmpty) {
                    return 'seleccione el sexo';
                  }
                  return null;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      DateTime currentDate = DateTime.now();
                      DateTime initialDate = DateTime(currentDate.year - 18,
                          currentDate.month, currentDate.day);

                      DateTime maxDate = DateTime(currentDate.year - 18,
                          currentDate.month, currentDate.day);

                      showCupertinoModalPopup(
                        barrierColor: const Color.fromARGB(54, 13, 117, 53),
                        context: context,
                        builder: (BuildContext context) => SizedBox(
                          height: 250,
                          child: CupertinoDatePicker(
                            backgroundColor: Colors.white,
                            initialDateTime: initialDate,
                            maximumDate: maxDate,
                            minimumYear: currentDate.year - 80,
                            maximumYear: currentDate.year - 18,
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
                ),
                readOnly: true,
                controller: _fechaController,
                keyboardType: TextInputType.datetime,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: true,
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'email',
                  hintText: 'Ingrese el email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el email';
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'telefono',
                  hintText: 'Ingrese el telefono',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el email';
                  }
                  return null;
                },
              ),
              IconButton(
                onPressed: _selectImageSource,
                icon: const Icon(Icons.add_photo_alternate),
              ),
            ],
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
              

              _signUp();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Procesando Datos')),
              );
              
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
  void _signUp() async {
                setState(() {
                  isSigningUp = true;
                });

                String email = _emailController.text;
                String password = '${_apellidoController.text.toString().capitalizeFirst}${_nombreController.text.toString().toLowerCase()}_1';
                String name = _nombreController.text;

                User? user =
                    await _auth.signUpWithEmailAndPassword(email, password);

                
                  isSigningUp = false;
                

                if (user != null) {
                  currentUser.updateDisplayName('trabajador');
                  currentUser.updatePhotoURL('$imageUrl');
                  //user.displayName = _nameController.text;
                  String userId =user.uid; // Obtiene el ID del usuario recién creado
                  crearUser(userId);
                  showToast(message: "Usuario creado exitosamente");
                  
                } else {
                  showToast(message: "Ha ocurrido un error");
                }
              }
  void crearUser(String userId)async{


    DateTime fechaNacimiento = DateTime.parse(_fechaController.text);
    
  
    await addUserT(
      userId, 
      _nombreController.text, 
      _apellidoController.text, 
      _emailController.text, 
      _telefonoController.text, 
      currentUser.uid, 
      fechaNacimiento, 
      _sexoController.text,
      widget.finca,
      'trabajador'
      ).then((_){
        setState(() {
          Navigator.pop(context);
        });
      });
  }
}
