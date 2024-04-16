import 'dart:math';

import 'package:flutter/material.dart';

class FarmPage extends StatelessWidget {
  const FarmPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          final random = Random();
          final randomNumber = 100 + random.nextInt(900);
          return ListTile(
            leading: const Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.gif_box,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
            title: const Text(
              "Lote",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(randomNumber.toString()),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        onPressed: () {},
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
