// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moo/features/user_auth/presentation/pages/animal_page.dart';
import 'package:moo/features/user_auth/presentation/pages/farm_page.dart';
import 'package:moo/features/user_auth/presentation/pages/home_page.dart';
import 'package:moo/features/user_auth/presentation/pages/porfile_page.dart';
import 'package:moo/features/user_auth/presentation/pages/production_page.dart';
import 'package:moo/features/user_auth/presentation/widgets/drawer_widget.dart';
import 'package:moo/global/common/toast.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentIndex = 0;
  static const List body = [
    HomePage(),
    FarmPage(),
    AnimalPage(),
    ProductionPage(),
    PorfilePage(),
  ];
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
      drawer: DrawerWidget(
        onProfileTap: _profile,
        onSignUp: _logout,
      ),
      appBar: AppBar(
          backgroundColor: Colors.green.shade800,
          title: const Text(
            "Moo",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                color: Colors.white)
          ],
          iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: body.elementAt(currentIndex),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
              icon: Icon(FontAwesomeIcons.bath), label: 'Fincas'),
          NavigationDestination(
              icon: Icon(Icons.add_task_sharp), label: 'Animales'),
          NavigationDestination(
              icon: Icon(Icons.add_task_sharp), label: 'Producción'),
          NavigationDestination(icon: Icon(Icons.person_2), label: 'Perfil'),
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
