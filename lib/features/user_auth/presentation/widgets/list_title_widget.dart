import 'package:flutter/material.dart';

class ListTitleWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  const ListTitleWidget(
      {super.key, required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: Colors.white,
      ),
      onTap: onTap,
      title: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }
}
