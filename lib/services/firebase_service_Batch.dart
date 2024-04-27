import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moo/services/firebase_service_Farm.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
final  currentUser = FirebaseAuth.instance.currentUser!;
Future<List<Map<String, dynamic>>> getLotes() async {
  List<Map<String, dynamic>> lotes = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceLotes = db.collection("lotes");
  
  // Realizar la consulta filtrando por el campo 'user'
  QuerySnapshot queryLotes = await collectionReferenceLotes.where('user', isEqualTo: currentUser.uid).get();
  
  for (DocumentSnapshot documento in queryLotes.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    
    final lote = {
      'nombre': data['nombre'],
      'cantidad': data['cantidad'],
      'uid': documento.id,
      'finca': data['finca'],
    };
    lotes.add(lote);
  }
  
  // Simular un pequeño retraso antes de devolver los lotes
  await Future.delayed(const Duration(milliseconds: 5));
  return lotes;
}


Future<void> addBatch(String nombre, int cantidad, String finca) async {
  
  
  await db.collection('lotes').add({
    'nombre': nombre,
    'cantidad': cantidad,
    'finca': finca,
    'user':currentUser.uid
  });
}

Future<void> updateBatch(String uid, String newNombre, int newCantidad) async {
  await db.collection('lotes').doc(uid).update({
    'nombre': newNombre,
    'cantidad': newCantidad,
  });
}

Future<void> deleteBatch(String uid) async {
  await db.collection('lotes').doc(uid).delete();
}
