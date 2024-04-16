// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moo/features/user_auth/presentation/pages/login_page.dart';
import 'package:moo/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:moo/global/common/toast.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
      body: Center(
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
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Restablecer contraseña",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              FormContainerWidget(
                hintText: "Correo electrónico",
                controller: _emailController,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Te envíarémos un link a tu correo de restablecimiento de contraseña.",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: _sendResetEmail,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green.shade800,
                  ),
                  child: const Center(
                    child: Text("Restablecer contraseña",
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
                        "Regresar",
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
    );
  }

  void _sendResetEmail() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text(
                "Enlace de restablecimiento de contraseña enviado.\nCompruebe su correo electrónico"),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      showToast(message: "Ha ocurrido un error: ${e.message}");
    }
  }
}
