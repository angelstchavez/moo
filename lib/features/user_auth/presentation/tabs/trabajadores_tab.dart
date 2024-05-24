import 'package:flutter/material.dart';
import 'package:moo/features/user_auth/presentation/pages/AddTrabajdor.dart';
import 'package:moo/services/firebase_service_Farm.dart';

class ProductionTab extends StatefulWidget {
  const ProductionTab({super.key});

  @override
  State<ProductionTab> createState() => _ProductionTabState();
}

class _ProductionTabState extends State<ProductionTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Ventana de trabajadores")),


      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 17, 63, 8),
        onPressed: () async {
          List<Map<String, dynamic>> fincas = await getFincas();
                          String finca = fincas[0]['uid'];

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddTrabajador(
                finca: finca,
                jefe: currentUser.uid,
               
              );
            },
          );
          
        },
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,size: 37,
        ),
      ),
    );
  }
}
