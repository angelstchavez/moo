import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getLotes() async {
  List lotes = [];
  CollectionReference collectionReferenceFincas = db.collection("lotes");
  QuerySnapshot queryLotes = await collectionReferenceFincas.get();
  queryLotes.docs.forEach((documento) {

    final Map<String,dynamic> data = documento.data() as Map<String,dynamic>;
    final lote ={
      'nombre': data['nombre'],
      'cantidad': data['cantidad'],
      'uid': documento.id,
    };
    lotes.add(lote);
  });
  await Future.delayed(const Duration(milliseconds: 5));
  return lotes;
}

Future<void> addBatch_(String nombre, int cantidad) async{

await db.collection('lotes').add(
  { 'nombre':nombre,
    'cantidad':cantidad
  });
  

} 

Future<void> updateBatch(String uid, String newNombre,int newCantidad) async{
  await db.collection('lotes').doc(uid).set({
    'nombre':newNombre,
    'cantidad':newCantidad
  });
}


Future<void> deleteBatch(String uid) async{
  await db.collection('lotes').doc(uid).delete();
}