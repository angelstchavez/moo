// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:moo/features/user_auth/presentation/pages/porfile_page.dart';
import 'package:moo/features/user_auth/presentation/widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../global/common/toast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamed(context, "/login");
      showToast(message: "Sesión cerrada exitosamente");
    } catch (e) {
      showToast(message: "Error al cerrar sesión: $e");
    }
  }

  void _profile() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PorfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green.shade800,
        title: const Text(
          "Moo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            color: Colors.white,
          )
        ],
      ),
      drawer: DrawerWidget(
        onProfileTap: _profile,
        onSignUp: _logout,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Bandeja principal")],
        ),
      ),
    );
  }
}
