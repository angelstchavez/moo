// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:gap/gap.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moo/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:moo/features/user_auth/presentation/pages/home_page.dart';
import 'package:moo/features/user_auth/presentation/pages/reset_password_page.dart';
import 'package:moo/features/user_auth/presentation/pages/signInGoogle.dart';
import 'package:moo/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:moo/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:moo/features/user_auth/presentation/widgets/navigation_bar.dart';
import 'package:moo/features/user_auth/presentation/widgets/square_title_widget.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_service_Farm.dart';
import 'package:moo/services/firebase_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuthServices _auth = FirebaseAuthServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Gap(100),
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
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  "Bienvenido",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                FormContainerWidget(
                  hintText: "Correo electrónico",
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  hintText: "Contraseña",
                  controller: _passwordController,
                  isPasswordField: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ResetPasswordPage()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Olvidaste tu contraseña?",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: _signIn,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green.shade800,
                    ),
                    child: Center(
                      child: _isSigning
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Iniciar sesión",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    )),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "ó continua con",
                          style: TextStyle(color: Colors.grey[700]),
                        )),
                    Expanded(
                        child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    )),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _signInWithGoogle,
                      child: const SquareTitleWidget(
                          imagePath: "assets/icon/google.png"),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    // GestureDetector(
                    //   onTap: _signInWithFacebook,
                    //   child: const SquareTitleWidget(
                    //       imagePath: "assets/icon/facebook.png"),
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        "No tienes cuenta? ",
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Regístrate",
                          style: TextStyle(
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

  bool? state;

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);

      if (user != null) {
        final currentUser = FirebaseAuth.instance.currentUser!;
        // Verificar el estado del usuario en Firestore
        List<Map<String, dynamic>> usuarios =
            await getUserById(currentUser.uid);
        if (usuarios.isNotEmpty) {
          if (!mounted) return; // Verifica si el widget está montado
          setState(() {
            state = usuarios.first['state'];
          });
        }

        if (state == true) {
          showToast(message: "Inicio de sesión exitoso");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (builder) =>  NavBar()),
            (route) => false,
          );
        } else {
          showToast(message: "Usuario inactivo. Contacta al administrador.");
          await _firebaseAuth.signOut(); // Cerrar sesión del usuario inactivo
        }
      } else {
        showToast(message: "Ha ocurrido un error");
      }
    } catch (e) {
      showToast(message: "Error al iniciar sesión: $e");
    } finally {
      setState(() {
        _isSigning = false;
      });
    }
  }

  void _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        if (googleSignInAuthentication.idToken != null &&
            googleSignInAuthentication.accessToken != null) {
          final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken,
          );

          UserCredential userCredential =
              await _firebaseAuth.signInWithCredential(credential);

          // Aquí se obtiene el usuario por email después de autenticarse
          
              Get.to(()=> NavBar(email: '${userCredential.user?.email}',id: '${userCredential.user?.uid}',));
          
        } else {
          showToast(message: "Error al obtener token de Google.");
        }
      }
    } catch (e) {
      showToast(message: "Error al iniciar sesión con Google: $e");
    }
  }

  // void _signInWithFacebook() async {
  //   try {
  //     // Inicia sesión con Facebook
  //     final LoginResult result = await FacebookAuth.instance.login();

  //     if (result.status == LoginStatus.success) {
  //       final OAuthCredential credential =
  //           FacebookAuthProvider.credential(result.accessToken!.token);

  //       UserCredential userCredential =
  //           await _firebaseAuth.signInWithCredential(credential);

  //       // Verificar el estado del usuario en Firestore
  //       DocumentSnapshot userDoc = await _firestore
  //           .collection('usuarios')
  //           .doc(userCredential.user?.uid)
  //           .get();

  //       if (userDoc.exists &&
  //           userDoc.data() != null &&
  //           userDoc['state'] == true) {
  //         Navigator.pushNamed(context, "/home");
  //       } else {
  //         showToast(message: "Usuario inactivo. Contacta al administrador.");
  //         await _firebaseAuth.signOut(); // Cerrar sesión del usuario inactivo
  //       }
  //     } else if (result.status == LoginStatus.cancelled) {
  //       showToast(message: "Inicio de sesión con Facebook cancelado");
  //     } else {
  //       showToast(
  //           message:
  //               "Ha ocurrido un error durante el inicio de sesión con Facebook");
  //     }
  //   } catch (e) {
  //     showToast(message: "Error al iniciar sesión con Facebook: $e");
  //   }
  // }
}
