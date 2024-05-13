
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
final  currentUser = FirebaseAuth.instance.currentUser!;
Future<List<Map<String, dynamic>>> getFincas() async {
  List<Map<String, dynamic>> fincas = [];
  CollectionReference collectionReferenceFincas = db.collection("fincas");
  QuerySnapshot queryFincas = await collectionReferenceFincas.where('usuario', isEqualTo: currentUser.uid).get();

  

  for (DocumentSnapshot documento in queryFincas.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    
    // Obtener la referencia a la finca
    //DocumentReference fincaRef = data['finca'];
    // Obtener los datos de la finca utilizando la referencia
    //DocumentSnapshot fincaSnapshot = await fincaRef.get();
    //final Map<String, dynamic> fincaData = fincaSnapshot.data() as Map<String, dynamic>;

    final finca = {
      'nombre': data['nombre'],
      'fecha': data['fecha'],
      'uid': documento.id,
      'usuario': data['usuario'],
      'tamano': data['tamano'],
      
    };
    fincas.add(finca);
  }
  await Future.delayed(const Duration(milliseconds: 5));
  return fincas;
}

Future<void> addFarm(String nombre, int tamano,String user) async {
  DateTime now = DateTime.now();
  String formattedDate = "${now.year}-${now.month}-${now.day}";

  await db.collection('fincas').add({
    'nombre': nombre,
    'tamano':tamano,
    //'ubicacion':ubicacion,

    'fecha': formattedDate,
    'usuario':user,

  });
}

Future<void> updateFarm(String uid,) async {
  await db.collection('fincas').doc(uid).update({
    'usuario': currentUser.uid,
  });
}

Future<void> deleteFarm(String uid) async {
  await db.collection('fincas').doc(uid).delete();
}
