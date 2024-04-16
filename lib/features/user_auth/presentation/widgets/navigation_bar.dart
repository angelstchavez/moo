// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moo/features/user_auth/presentation/widgets/drawer_widget.dart';
import 'package:moo/global/common/toast.dart';


class NavBar extends StatefulWidget {
  const NavBar({Key? key}): super(key:key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {

  int currentIndex = 0;
  static const List body =[
    Icon(Icons.home_outlined,size: 50),
    Icon(Icons.local_florist_outlined,size: 50),
    Icon(Icons.settings_outlined,size: 50),
    Icon(Icons.person_2_outlined,size: 50),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        // automaticallyImplyLeading: true,
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
        destinations: const[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.local_florist), label: 'Fincas'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
          NavigationDestination(icon: Icon(Icons.person_2), label: 'Perfil'),
        ],
        selectedIndex: currentIndex,
        onDestinationSelected: (int index){
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}