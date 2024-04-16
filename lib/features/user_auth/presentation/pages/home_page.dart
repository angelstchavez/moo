// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moo/features/user_auth/presentation/tabs/animal_tab.dart';
import 'package:moo/features/user_auth/presentation/tabs/batch_tab.dart';
import 'package:moo/features/user_auth/presentation/tabs/farm_tab.dart';
import 'package:moo/features/user_auth/presentation/tabs/production_tab.dart';
import 'package:moo/features/user_auth/presentation/widgets/tab_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> tabs = const [
    TabWidget(iconPath: "assets/icon/granja.png"),
    TabWidget(iconPath: "assets/icon/valla.png"),
    TabWidget(iconPath: "assets/icon/vaca.png"),
    TabWidget(iconPath: "assets/icon/carne.png"),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                //greatings row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hola, Emilio!",
                          style: TextStyle(
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
                //Tabbar
                TabBar(tabs: tabs),
                const Expanded(
                    child: TabBarView(children: [
                  FarmTab(),
                  BatchTab(),
                  AnimalTab(),
                  ProductionTab(),
                ]))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
