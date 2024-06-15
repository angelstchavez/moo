// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/addAnimal.dart';
import 'package:moo/features/user_auth/presentation/pages/animals/animal_page.dart';
import 'package:moo/features/user_auth/presentation/pages/batches/batch_page.dart';
import 'package:moo/features/user_auth/presentation/pages/farms/farm_page.dart';
import 'package:moo/features/user_auth/presentation/pages/home_page.dart';
import 'package:moo/features/user_auth/presentation/pages/porfile_page.dart';
import 'package:moo/features/user_auth/presentation/pages/production_page.dart';
import 'package:moo/features/user_auth/presentation/pages/signInGoogle.dart';
import 'package:moo/features/user_auth/presentation/widgets/drawer_widget.dart';
import 'package:moo/global/common/toast.dart';
import 'package:moo/services/firebase_user.dart';

// ignore: must_be_immutable
class NavBar extends StatefulWidget {
  String? email;
  String? id;
  NavBar({Key? key, this.email, this.id}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentIndex = 0;

  void newAccountGoogle() async {
    List<Map<String, dynamic>> user = await getUserByemail(widget.email);
    String? email = user.isNotEmpty ? user[0]['email'] : null;

    if (email == null) {
      await showDialog(
        barrierDismissible: false,
        barrierColor: Colors.grey,

        context: context,
        builder: (BuildContext context) {
          return AddUserAndFarmGoogle(
            email: widget.email!,
            id: widget.id!,
          );
        },
      ).whenComplete((){
        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavBar()
                            ),
                          );
      });
    }

    // Si el usuario no existe, se muestra el diálogo para añadirlo
  }

  @override
  void initState() {
    newAccountGoogle();

    super.initState();
  }

  static const List body = [
    HomePage(),
    BatchPage(),
    AnimalPage(),
    //ProductionPage(),
    // ProfilePage(),
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
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void _trabajador() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(
        onProfileTap: _profile,
        onSignUp: _logout,
        // onTrabajadorTap: _trabajador,
      ),
      appBar: AppBar(
          backgroundColor: Colors.green.shade800,
          title: const Text(
            "Moo App",
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
        indicatorColor: Colors.grey.shade300,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: Colors.grey.shade600,
              size: 30,
            ),
            selectedIcon: const Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
              icon: Icon(
                Icons.agriculture_outlined,
                color: Colors.grey.shade600,
                size: 30,
              ),
              selectedIcon: const Icon(
                Icons.agriculture,
                size: 30,
              ),
              label: 'Finca'),

          NavigationDestination(
              icon: Icon(
                Icons.assignment_outlined,
                color: Colors.grey.shade600,
                size: 30,
              ),
              selectedIcon: const Icon(
                Icons.assignment,
                size: 30,
              ),
              label: 'Animales'),
          // NavigationDestination(
          //     icon:
          //         Icon(Icons.view_agenda_rounded, color: Colors.grey.shade600),
          //     label: 'Producción'),
          // NavigationDestination(
          //   icon: Icon(Icons.person_2, color: Colors.grey.shade600),
          //   label: 'Perfil',
          // ),
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
