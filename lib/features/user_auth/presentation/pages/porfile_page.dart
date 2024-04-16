import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PorfilePage extends StatefulWidget {
  const PorfilePage({super.key});

  @override
  State<PorfilePage> createState() => _PorfilePageState();
}

class _PorfilePageState extends State<PorfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const Icon(
                Icons.person,
                size: 72,
                color: Colors.green,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                currentUser.email!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.green.shade800, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
