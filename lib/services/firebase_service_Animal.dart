import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


FirebaseFirestore db = FirebaseFirestore.instance;
final  currentUser = FirebaseAuth.instance.currentUser!;
Future<List<Map<String, dynamic>>> getVacasByLote(String lote) async {
  List<Map<String, dynamic>> vacas = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceLotes = db.collection("animales");
  
  // Realizar la consulta filtrando por el campo 'user'
  QuerySnapshot queryVacas = await collectionReferenceLotes.where('lote', isEqualTo: lote).where('state',isEqualTo: true).get();
  
  for (DocumentSnapshot documento in queryVacas.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    
    final vaca = {
      'uid': documento.id,
      'nombre': data['nombre'],
      'raza': data['raza'],
      'fecha':data['fecha'],
      'produccion': data['produccion'],
      //"Referencias"
      'user': data['user'],
      'finca': data['finca'],
      'lote':data['lote'],
      'img':data['img'],
      'state':data['state'],
    };
    vacas.add(vaca);
  }
  
  // Simular un pequeño retraso antes de devolver los lotes
  
  await Future.delayed(const Duration(milliseconds: 5));
  
  return vacas;
}

Future<List<Map<String, dynamic>>> getAllVacas() async {
  List<Map<String, dynamic>> vacas = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceLotes = db.collection("animales");
  
  // Realizar la consulta filtrando por el campo 'user'
  QuerySnapshot queryVacas = await collectionReferenceLotes.where('user', isEqualTo: currentUser.uid).get();
  
  for (DocumentSnapshot documento in queryVacas.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    
    final vaca = {
      'uid': documento.id,
      'nombre': data['nombre'],
      'raza': data['raza'],
      'fecha':data['fecha'],
      'produccion': data['produccion'],
      //"Referencias"
      'user': data['user'],
      'finca': data['finca'],
      'lote':data['lote'],
      'img':data['img'],
    };
    vacas.add(vaca);
  }
  
  // Simular un pequeño retraso antes de devolver los lotes
  await Future.delayed(const Duration(milliseconds: 5));
  return vacas;
}
Future<Map<String, dynamic>?> getLotesById(String uid) async {
  // Obtener referencia al documento del lote mediante su uid
  DocumentSnapshot snapshot =
      await db.collection("lotes").doc(uid).get();

  // Verificar si el documento existe
 
    // Obtener los datos del documento
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return {
      'nombre': data['nombre'],
      'cantidad': data['cantidad'],
      'uid': snapshot.id,
      'finca': data['finca'],
    };
  
}

Future<void> addAnimal(String nombre, String raza, DateTime fecha,String lote,String finca,String? image) async {
 
 String formattedDate = "${fecha.year}-${fecha.month}-${fecha.day}";
  await db.collection('animales').add({
    'nombre': nombre,
      'raza': raza,
      'fecha':formattedDate,
      'produccion': null,
      //"Referencias"
      'user': currentUser.uid,
      'finca': finca,
      'lote':lote,
      'img': image,
      'state':true
  });
}






Future<void> updateBatch(String uid, String newNombre, int newCantidad) async {
  await db.collection('lotes').doc(uid).update({
    'nombre': newNombre,
    'cantidad': newCantidad,
  });
}

Future<void> deleteAnimal(String uid) async {
  
  await db.collection('animales').doc(uid).update({
    'state':false
  });
}
