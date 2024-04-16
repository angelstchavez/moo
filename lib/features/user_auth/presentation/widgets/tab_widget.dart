import 'package:flutter/material.dart';

class TabWidget extends StatelessWidget {
  final String iconPath;

  const TabWidget({Key? key, required this.iconPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 80,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          iconPath,
        ),
      ),
    );
  }
}
