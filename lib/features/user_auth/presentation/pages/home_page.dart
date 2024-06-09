import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moo/features/user_auth/presentation/tabs/animal_tab.dart';
import 'package:moo/features/user_auth/presentation/tabs/batch_tab.dart';
import 'package:moo/features/user_auth/presentation/tabs/farm_tab.dart';

import 'package:moo/features/user_auth/presentation/tabs/trabajadores_tab.dart';
import 'package:moo/features/user_auth/presentation/widgets/tab_widget.dart';
import 'package:moo/services/firebase_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  late List<Widget> tabs;
  late List<Widget> tabViews;
  String? img;
  String? nombre;

  @override
  void initState() {
    _loadUserData();
    super.initState();

    // Define tabs and tab views based on the displayName
    if (currentUser.displayName == 'trabajador') {
      tabs = const [
        TabWidget(iconPath: "assets/icon/granja.png"),
        //TabWidget(iconPath: "assets/icon/valla.png"),
      ];
      tabViews = const [
        FarmTab(),
        //BatchTab(),
      ];
    } else {
      tabs = const [
        TabWidget(iconPath: "assets/icon/granja.png"),
        //TabWidget(iconPath: "assets/icon/valla.png"),
        TabWidget(iconPath: "assets/icon/vaca.png"),
        TabWidget(iconPath: "assets/icon/granjero.png"),
      ];
      tabViews = const [
        FarmTab(),
        //BatchTab(),
        AnimalTab(),
        TrabajadorTab(),
      ];
    }
  }
  
  Future<void> _loadUserData() async {
    try {
      List<Map<String, dynamic>> users = await getUserByUser();
      if (users.isNotEmpty) {
        setState(() {
          img = users[0]['img'];
          nombre = users[0]['nombre'];
          
        });
      }
    } catch (e) {
      // Handle error
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: PopScope(  // Corrected from PopScope
        canPop: false,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Greetings row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            CircleAvatar(
                              radius: 40,
                            backgroundImage: img != null ? NetworkImage(img!) : null,
                            child: img == null ? Icon(Icons.person) : null,
                          ),
                          Text(
                            "Hola, $nombre",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMMM, yyyy').format(DateTime.now()),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // TabBar
                  TabBar(
                    tabs: tabs,
                    dividerColor: Colors.green,
                    indicatorColor: Colors.brown,
                    indicatorWeight: 5,
                  
                  
                  ),
                  
                  // TabBarView
                  Expanded(
                    child: TabBarView(children: tabViews),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
