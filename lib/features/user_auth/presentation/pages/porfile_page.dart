import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moo/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:moo/features/user_auth/presentation/widgets/imput_decoration.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? id;
  String? img;
  String? imageUrl;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      List<Map<String, dynamic>> users = await getUserByUser();
      if (users.isNotEmpty) {
        setState(() {
          img = users[0]['img'];
          imageUrl = users[0]['img'];

          id = users[0]['uid'];
          _nameController.text = users[0]['nombre'];
          _apellidoController.text = users[0]['apellido'];
          _heightController.text = users[0]['altura']?.toString() ?? '';
          _weightController.text = users[0]['peso']?.toString() ?? '';
          _phoneController.text = users[0]['telefono'] ?? '';
        });
      }
    } catch (e) {
      // Handle error
      print('Error loading user data: $e');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = true,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Colors.black,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      readOnly: readOnly,
      decoration: InputDecorations.inputDecotation(
        hintext: hint,
        labeltext: label,
        icono: Icon(
          icon,
          color: Colors.green,
        ),
      ),
      validator: validator,
    );
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

        currentUser.updatePhotoURL(downloadUrl);
        updateImgUser(id, '$imageUrl');
      });
      //    Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (BuildContext context) => const ProfilePage(),
      //   ),
      // );
    } catch (e) {
      // Manejo de errores
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade800,
        title: Text(
          'Perfil',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                  isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined))
        ],
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      radius: 60,
                      backgroundImage: imageUrl != null
                          ? NetworkImage('$imageUrl')
                          : null,
                      child: imageUrl == null
                          ? const Icon(Icons.person,
                              color: Colors.grey, size: 60)
                          : null,
                    ),
                    Positioned(
                      right: -6,
                      bottom: -15,
                      child: IconButton(
                        icon: const Icon(
                          Icons.add_photo_alternate,
                          color: Colors.blue,
                          size: 30,
                        ),
                        onPressed: () async {
                          _selectImageSource();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(40),
                const Divider(
                  thickness: 0.2,
                ),
                const Gap(30),
                ExpansionTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.green.shade50),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.amber,
                    ),
                  ),
                  title: const Text('Informacion'),
                  iconColor: Colors.green,
                  backgroundColor: Colors.grey.shade100,
                  collapsedIconColor: Colors.black,
                  expansionAnimationStyle: AnimationStyle(
                      curve: Curves.easeInCirc, duration: Durations.extralong1),
                  children: [
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.green.shade50),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.lime,
                        ),
                      ),
                      title: const Text('Editar'),
                      trailing: Switch(
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey,
                        value: isEditing,
                        onChanged: (value) async {
                          setState(() {
                            isEditing = value; // Actualiza el valor de parto
                            if (isEditing == false) {
                              Fluttertoast.showToast(
                                msg: 'No editable...',
                                backgroundColor: Colors.red,
                                webPosition: 'left',
                                fontSize: 20,
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Editable...',
                                backgroundColor: Colors.green,
                                webPosition: 'left',
                                fontSize: 20,
                              );
                            }
                          });
                        },
                      ),
                    ),
                    const Gap(15),
                    TextFormField(
                      readOnly: !isEditing,
                      controller: _nameController,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'nombre',
                          hintText: 'ingrese el nombre',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 20),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          floatingLabelStyle:
                              const TextStyle(color: Colors.black),
                          hintStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el nombre';
                        }
                        if (value.length > 15) {
                          return 'El nombre permite maximo 15 dígitos';
                        }

                        return null;
                      },
                    ),
                    const Gap(20),
                    TextFormField(
                      readOnly: !isEditing,
                      controller: _apellidoController,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'apellido',
                          hintText: 'ingrese el apellido',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 20),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          floatingLabelStyle:
                              const TextStyle(color: Colors.black),
                          hintStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el apellido';
                        }
                        if (value.length > 15) {
                          return 'El apellido permite maximo 15 dígitos';
                        }

                        return null;
                      },
                    ),
                    const Gap(20),
                    TextFormField(
                      readOnly: !isEditing,
                      controller: _phoneController,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          prefixText: '+ ',
                          prefixIcon: const Icon(Icons.phone),
                          labelText: 'telefono',
                          hintText: 'ingrese el telefono',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 20),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          floatingLabelStyle:
                              const TextStyle(color: Colors.black),
                          hintStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(100))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese el teléfono';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Solo se permiten números';
                        }
                        if (value.length < 10) {
                          return 'El número de teléfono debe tener al menos 10 dígitos';
                        }
                        return null;
                      },
                    ),
                    const Gap(20),
                    const Gap(20),
                    
                  ],
                ),
                const Divider(
                  thickness: 0.5,
                ),
                ListTile(
                  onTap: _logout,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.green.shade50),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.amber,
                      ),
                    ),
                    title: const Text('Cerrar Sesión'))
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _logout() async {
    try {
      
      
        await FirebaseAuth.instance.signOut();


       Navigator.pushNamed(context, "/login");
      showToast(message: "Sesión cerrada exitosamente");
    } catch (e) {
      showToast(message: "Error al cerrar sesión: $e");
    }
  }
}
