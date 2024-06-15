

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
      'idJefe':data['idJefe'],
      'userId':data['userId'],
      'nombre': data['nombre'],
      'apellido': data['apellido'],
      'telefono': data['telefono'],
      'uid': documento.id,
      'email': data['email'],
      'img': data['img'],
      'rol': data['rol'],
      'state': data['state'],
      
    };
    users.add(usuario);
  }

  // Simular un pequeño retraso antes de devolver los lotes
  await Future.delayed(const Duration(milliseconds: 5));
  return users;
}
Future<List<Map<String, dynamic>>> getUserById(id) async {
  List<Map<String, dynamic>> users = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceUsuarios = db.collection("usuarios");

  // Realizar la consulta filtrando por el campo 'user'
  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.where('userId',isEqualTo:id ).get();

  for (DocumentSnapshot documento in queryUsuarios.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;

    final usuario = {
      'idJefe':data['idJefe'],
      'userId':data['userId'],
      'nombre': data['nombre'],
      'apellido': data['apellido'],
      'telefono': data['telefono'],
      'uid': documento.id,
      'email': data['email'],
      'img': data['img'],
      'rol': data['rol'],
      'state': data['state'],
      
    };
    users.add(usuario);
  }

  // Simular un pequeño retraso antes de devolver los lotes
  await Future.delayed(const Duration(milliseconds: 5));
  return users;
}
Future<List<Map<String, dynamic>>> getUserByemail(email) async {
  List<Map<String, dynamic>> users = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceUsuarios = db.collection("usuarios");

  // Realizar la consulta filtrando por el campo 'user'
  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios.where('email',isEqualTo:email ).get();

  for (DocumentSnapshot documento in queryUsuarios.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;

    final usuario = {
      
      'email': data['email'],

    };
    users.add(usuario);
  }

  // Simular un pequeño retraso antes de devolver los lotes
  await Future.delayed(const Duration(milliseconds: 5));
  return users;
}
Future<List<Map<String, dynamic>>> getUserByJefe() async {
  List<Map<String, dynamic>> users = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceUsuarios = db.collection("usuarios");

  // Realizar la consulta filtrando por el campo 'user'
  QuerySnapshot queryUsuarios = await collectionReferenceUsuarios
  .where('idJefe',isEqualTo:currentUser.uid )
  .where('rol',isEqualTo: 'trabajador').get();

  for (DocumentSnapshot documento in queryUsuarios.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    
    final usuario = {
      'idJefe':data['idJefe'],
      'userId':data['userId'],
      'nombre': data['nombre'],
      'apellido': data['apellido'],
      'telefono': data['telefono'],
      'uid': documento.id,
      'email': data['email'],
      'img': data['img'],
      'rol': data['rol'],
      'state': data['state'],
      
    };
    users.add(usuario);
    
  }

  // Simular un pequeño retraso antes de devolver los lotes
  await Future.delayed(const Duration(milliseconds: 5));
  return users;
}

Future<void> addUserT(String user,String nombre, String apellido, String email,String telefono,String jefe,DateTime fecha,String sexo,String finca,String rol,String? img) async {
  String formattedDate = "${fecha.year}-${fecha.month}-${fecha.day}";
  await db.collection('usuarios').add({
    'idJefe':jefe,
    'userId':user,
    'nombre': nombre,
    'apellido':apellido,
    'email': email,
    'telefono':telefono,
    'img':img,
    'rol':rol,
    'sexo':sexo,
    'fechaNacimiento':formattedDate,
    'finca':finca,
    'state':true
  });
}
Future<void> addUserP(String user,String jefe,String? nombre, String? apellido, String email,String? telefono) async {
  
  await db.collection('usuarios').add({
    
    'userId':user,
    'nombre': nombre,
    'apellido':apellido,
    'email': email,
    'telefono':telefono,
    'img':null,
    'idJefe':jefe,
    'sexo':null,
    'fechaNacimiento':null,
    'state':true
    
  });
}

Future<void> updateUser(String? uid,String nombre, String apellido,String telefono) async {
  await db.collection('usuarios').doc(uid).update({
    'nombre': nombre,
    'apellido':apellido,
    'telefono': telefono,
    
  
  });
}
Future<void> updateImgUser(String? uid, String img) async {
  await db.collection('usuarios').doc(uid).update({
    'img': img
    
  
  });
}
Future<void> updateStateUser(String uid,bool state) async {
  await db.collection('usuarios').doc(uid).update({
    'state':state
  });
}
Future<void> deleteUser(String uid) async {
  await db.collection('usuarios').doc(uid).delete();
}


