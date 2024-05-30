
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
final  currentUser = FirebaseAuth.instance.currentUser!;
Future<List<Map<String, dynamic>>> getProductionByAnimal(idAnimal) async {
  List<Map<String, dynamic>> produccion = [];
  CollectionReference collectionReferenceProduccion = db.collection("produccion");
  QuerySnapshot queryProduccion = await collectionReferenceProduccion.where('animal', isEqualTo: idAnimal).get();

  

  for (DocumentSnapshot documento in queryProduccion.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    
    // Obtener la referencia a la finca
    //DocumentReference fincaRef = data['finca'];
    // Obtener los datos de la finca utilizando la referencia
    //DocumentSnapshot fincaSnapshot = await fincaRef.get();
    //final Map<String, dynamic> fincaData = fincaSnapshot.data() as Map<String, dynamic>;

    final production = {
      'animal': data['animal'],
      'fecha': data['fecha'],
      'uid': documento.id,
      'cantidad': data['cantidad'],
      
    };
    produccion.add(production);
  }
  await Future.delayed(const Duration(milliseconds: 5));
  return produccion;
}

Future<void> addProduccion(String animal, double cantidad,DateTime now ) async {
  
  String formattedDate = "${now.year}-${now.month}-${now.day}";

  await db.collection('produccion').add({
    'animal': animal,
    'cantidad':cantidad,
    'fecha': formattedDate,
    'usuario':currentUser.uid,

  });
}

Future<void>deleteProduccion(String uid)async {

  await db.collection('produccion').doc(uid).delete();

}





