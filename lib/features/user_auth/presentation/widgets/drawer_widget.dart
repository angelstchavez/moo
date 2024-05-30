import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moo/features/user_auth/presentation/widgets/list_title_widget.dart';
import 'package:moo/services/firebase_service_Animal.dart';

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
    final currentUser = FirebaseAuth.instance.currentUser!;
    return Drawer(
      backgroundColor: Colors.green.shade800,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  radius: 40,
                  backgroundImage: currentUser.photoURL != null
                      ? NetworkImage('${currentUser.photoURL}')
                      : null,
                  child: currentUser.photoURL == null
                      ? const Icon(Icons.person, color:Colors.lime,size: 40)
                      : null,
                ),
              ),

              // ListTile(
              // onTap: onProfileTap,
              //   leading: Container(
              //     width: 40,
              //     height: 40,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(100),
              //       color: Colors.green.shade50
              //     ),
              //     child: const Icon(Icons.home,color: Colors.lime,),

              //   ),
              //   title: const Text('Home',style: TextStyle(color: Colors.white),),
              //   trailing:Container(
              //     width: 40,
              //     height: 40,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(100),
              //       color: Colors.green.shade500
              //     ),
              //     child: const Icon(Icons.arrow_forward_ios_rounded,size: 18,color: Colors.white,),

              //   ),
              // ),
              // const Divider(thickness: 0.06,),
              ListTile(
                onTap: onProfileTap,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.green.shade50),
                  child: const Icon(
                    Icons.person,
                    color: Colors.lime,
                  ),
                ),
                title: const Text(
                  'Perfil',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.green.shade500),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const Divider(
                thickness: 0.06,
              ),
              ListTile(
                onTap: onTrabajadorTap,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.green.shade50),
                  child: const Icon(
                    Icons.groups_2,
                    color: Colors.lime,
                  ),
                ),
                title: const Text(
                  'Trabajadores',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.green.shade500),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                  onTap: onSignUp,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.green.shade50),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.amber,
                    ),
                  ),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.white),
                  ))),
        ],
      ),
    );
  }
}
