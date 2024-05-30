// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moo/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:moo/features/user_auth/presentation/pages/login_page.dart';
import 'package:moo/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Farm.dart';
import 'package:moo/services/firebase_user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreFincaController = TextEditingController();
  final TextEditingController _tamanoFincaController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nombreFincaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green.shade800,
        title: const Text(
          "Moo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            spreadRadius: 10,
                            blurRadius: 10,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/icon.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Administra tu agricultura con facilidad.",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Regístrate",
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Datos de La finca',
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    FormContainerWidget(
                      hintText: "Nombre de la finca",
                      controller: _nombreFincaController,
                    ),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    FormContainerWidget(
                      hintText: "Tamaño de la finca",
                      controller: _tamanoFincaController,
                      inputType: TextInputType.number,
                    ),
                  ],
                ),
                const Text(
                  'Datos de Usuario',
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    FormContainerWidget(
                      hintText: "Nombre",
                      controller: _nameController,
                    ),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    FormContainerWidget(
                      hintText: "Apellido",
                      controller: _apellidoController,
                    ),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    FormContainerWidget(
                      hintText: "Telefono",
                      controller: _phoneController,
                      inputType: TextInputType.phone,
                    ),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    FormContainerWidget(
                      hintText: "Correo electrónico",
                      controller: _emailController,
                    ),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    FormContainerWidget(
                      hintText: "Contraseña",
                      isPasswordField: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(
                      height: 20,
                      width: 20,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: _signUp,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green.shade800,
                    ),
                    child: const Center(
                      child: Text("Regístrate",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "Ya tienes cuenta? ",
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (route) => false);
                        },
                        child: Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    setState(() {
      isSigningUp = false;
    });

    if (user != null) {
      final currentUser = FirebaseAuth.instance.currentUser!;
      currentUser.updateDisplayName('propietario');
      //user.displayName = _nameController.text;
      String userId = user.uid; // Obtiene el ID del usuario recién creado
      crearFinca(userId);
      crearUser(userId); // Pasa el ID del usuario a la función crearFinca
      showToast(message: "Usuario creado exitosamente");
      Navigator.pushNamed(context, "/login");
    } else {
      showToast(message: "Ha ocurrido un error");
    }
  }

  void crearFinca(String userId) async {
    int tamano = int.tryParse(_tamanoFincaController.text) ?? 0;

    // Aquí puedes usar userId para asociar la finca con el usuario
    await addFarm(_nombreFincaController.text, tamano, userId);
  }

  void crearUser(String userId) async {
    await addUserP(userId, userId,_nameController.text, _apellidoController.text,
        _emailController.text, _phoneController.text);
  }
}
