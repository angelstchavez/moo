

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


FirebaseFirestore db = FirebaseFirestore.instance;
final currentUser = FirebaseAuth.instance.currentUser!;
Future<List<Map<String, dynamic>>> getUserByUser() async {
  List<Map<String, dynamic>> users = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceUsuarios = db.collection("usuarios");

  // Realizar la consulta filtrando por el campo 'user'
  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.where('userId',isEqualTo:currentUser.uid ).get();

  for (DocumentSnapshot documento in queryUsuarios.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;

    final usuario = {
      'userId':data['userId'],
      'nombre': data['nombre'],
      'apellido': data['apellido'],
      'rol':data['rol'],
      'telefono': data['telefono'],
      'uid': documento.id,
      'email': data['email'],
      'img': data['img'],
    };
    users.add(usuario);
  }

  // Simular un pequeño retraso antes de devolver los lotes
 // await Future.delayed(const Duration(milliseconds: 5));
  return users;
}

Future<void> addUser(String user,String nombre, String apellido, String email,String telefono,String rol,String jefe,DateTime fecha,String sexo,String finca) async {
  String formattedDate = "${fecha.year}-${fecha.month}-${fecha.day}";
  await db.collection('usuarios').add({
    'idJefe':jefe,
    'userId':user,
    'nombre': nombre,
    'apellido':apellido,
    'email': email,
    'telefono':telefono,
    'img':null,
    'rol':rol,
    'sexo':sexo,
    'fechaNacimiento':formattedDate,
    'finca':finca
  });
}

Future<void> updateUser(String? uid,String nombre, String apellido,num peso,num altura,String telefono,String?img) async {
  await db.collection('usuarios').doc(uid).update({
    'nombre': nombre,
    'apellido':apellido,
    'telefono': telefono,
    'img':img
  });
}


