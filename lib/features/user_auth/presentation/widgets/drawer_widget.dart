import 'package:flutter/material.dart';
import 'package:moo/features/user_auth/presentation/widgets/list_title_widget.dart';

class DrawerWidget extends StatelessWidget {
  final void Function()? onHomeTap;
  final void Function()? onProfileTap;
  final void Function()? onTrabajadorTap;
  final void Function()? onSignUp;

  const DrawerWidget({
    Key? key,
    this.onHomeTap,
    this.onProfileTap,
    this.onTrabajadorTap,
    this.onSignUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.green.shade800,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              ListTitleWidget(
                icon: Icons.home,
                text: "Inicio",
                onTap: onHomeTap,
              ),
              ListTitleWidget(
                icon: Icons.person,
                text: "Perfil",
                onTap: onProfileTap,
              ),
              ListTitleWidget(
                icon: Icons.groups_2_sharp,
                text: "Trabajadores",
                onTap: onTrabajadorTap,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTitleWidget(
              icon: Icons.logout,
              text: "Cerrar sesión",
              onTap: onSignUp,
            ),
          ),
        ],
      ),
    );
  }
}
