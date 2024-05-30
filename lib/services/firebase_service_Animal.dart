import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


FirebaseFirestore db = FirebaseFirestore.instance;
final  currentUser = FirebaseAuth.instance.currentUser!;
Future<List<Map<String, dynamic>>> getVacasByLote(String lote) async {
  List<Map<String, dynamic>> animales = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceAnimales = db.collection("animales");

  // Realizar la consulta filtrando por el campo 'lote' y 'state'
  QuerySnapshot queryVacas = await collectionReferenceAnimales
      .where('lote', isEqualTo: lote)
      .where('Sexo', isEqualTo: 'Hembra')

      .where('state', isEqualTo: true)
      .get();

  DateTime now = DateTime.now();

  for (DocumentSnapshot documento in queryVacas.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    DateTime fechaNacimiento = DateFormat('yyyy-M-d').parse(data['fecha']);
    int edad = now.difference(fechaNacimiento).inDays ~/ 365;

    int edadTernero;
     if(data['fechaParto'] != null){
      DateTime fechaParto = DateFormat('yyyy-M-d').parse(data['fechaParto']);
     edadTernero = now.difference(fechaParto).inDays ~/ 365;
     
     }else{
      edadTernero=0;
     }
    
    

    if (edad >= 3 ) {
      final animal = {
        'uid': documento.id,
        'nombre': data['nombre'],
        'raza': data['raza'],
        'sexo': data['sexo'],
        'fecha': data['fecha'],
        'produccion': data['produccion'],
        'user': data['user'],
        'finca': data['finca'],
        'lote': data['lote'],
        'img': data['img'],
        'state': data['state'],
        'parto': data['parto'],
        'esMadre': data['esMadre'],
        'idMadre':data['idMadre'],
        'fechaParto': data['fechaParto'],
        'edadTernero': edadTernero,
        
        'edad': edad,
      };
      animales.add(animal);
    }
  }

  // Simular un pequeño retraso antes de devolver los lotes
  await Future.delayed(const Duration(milliseconds: 5));

  return animales;
}
Future<List<Map<String, dynamic>>> getVacasByFinca(String finca) async {
  List<Map<String, dynamic>> animales = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceAnimales = db.collection("animales");

  // Realizar la consulta filtrando por el campo 'lote' y 'state'
  QuerySnapshot queryVacas = await collectionReferenceAnimales
      .where('finca', isEqualTo: finca)
      .where('Sexo', isEqualTo: 'Hembra')
      //.orderBy('produccion',descending: true)
     
      .where('state', isEqualTo: true)
      .get();

  DateTime now = DateTime.now();

  for (DocumentSnapshot documento in queryVacas.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    DateTime fechaNacimiento = DateFormat('yyyy-M-d').parse(data['fecha']);
    int edad = now.difference(fechaNacimiento).inDays ~/ 365;

    int edadTernero;
     if(data['fechaParto'] != null){
      DateTime fechaParto = DateFormat('yyyy-M-d').parse(data['fechaParto']);
     edadTernero = now.difference(fechaParto).inDays ~/ 365;
     
     }else{
      edadTernero=0;
     }
    
    

    if (edad >= 3 ) {
      final animal = {
        'uid': documento.id,
        'nombre': data['nombre'],
        'raza': data['raza'],
        'sexo': data['sexo'],
        'fecha': data['fecha'],
        'produccion': data['produccion'],
        'user': data['user'],
        'finca': data['finca'],
        'lote': data['lote'],
        'img': data['img'],
        'state': data['state'],
        'parto': data['parto'],
        'esMadre': data['esMadre'],
        'idMadre':data['idMadre'],
        'fechaParto': data['fechaParto'],
        'edadTernero': edadTernero,
        
        'edad': edad,
      };
      animales.add(animal);
    }
  }

  // Simular un pequeño retraso antes de devolver los lotes
  await Future.delayed(const Duration(milliseconds: 5));

  return animales;
}
Future<List<Map<String, dynamic>>> getNovillasSinLote(fincaId) async {
  List<Map<String, dynamic>> animales = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceAnimales = db.collection("animales");

  // Realizar la consulta filtrando por el campo 'lote' y 'state'
  QuerySnapshot queryVacas = await collectionReferenceAnimales
      .where('lote',isEqualTo: null)
      .where('finca',isEqualTo: fincaId)
      
      .where('state', isEqualTo: true)
      .get();

  DateTime now = DateTime.now();

  for (DocumentSnapshot documento in queryVacas.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    DateTime fechaNacimiento = DateFormat('yyyy-M-d').parse(data['fecha']);
    int edad = now.difference(fechaNacimiento).inDays ~/ 365;

    int edadTernero;
     if(data['fechaParto'] != null){
      DateTime fechaParto = DateFormat('yyyy-M-d').parse(data['fechaParto']);
     edadTernero = now.difference(fechaParto).inDays ~/ 365;
     
     }else{
      edadTernero=0;
     }
    
    

    if (edad >= 3 && data['lote']==null ) {
      final animal = {
        'uid': documento.id,
        'nombre': data['nombre'],
        'raza': data['raza'],
        'sexo': data['sexo'],
        'fecha': data['fecha'],
        'produccion': data['produccion'],
        'user': data['user'],
        'finca': data['finca'],
        'lote': data['lote'],
        'img': data['img'],
        'state': data['state'],
        'parto': data['parto'],
        'esMadre': data['esMadre'],
        'idMadre':data['idMadre'],
        'fechaParto': data['fechaParto'],
        'edadTernero': edadTernero,
        
        'edad': edad,
      };
      animales.add(animal);
    }
  }

  // Simular un pequeño retraso antes de devolver los lotes
  await Future.delayed(const Duration(milliseconds: 5));

  return animales;
}

Future<List<Map<String, dynamic>>> getAllVacas() async {
  List<Map<String, dynamic>> vacas = [];
  // Obtener referencia a la colección de lotes
  CollectionReference collectionReferenceLotes = db.collection("animales");
  
  // Realizar la consulta filtrando por el campo 'user'
  QuerySnapshot queryVacas = await collectionReferenceLotes.where('user', isEqualTo: currentUser.uid).where('state', isEqualTo: true).get();
  
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
      'parto':data['parto'],
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

Future<void> addAnimal(String nombre, String raza, DateTime fecha,String lote,String finca,String? image,bool adulto) async {
 
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
      'state':true,
      'esAdulto':adulto,
      'esMadre':false,
      'Sexo':'Hembra',
      'parto':false
  });
}



Future<void> addTernero(String nombre, String raza,String finca,String? image,String idMadre) async {

  DateTime fecha =DateTime.now();
 
 String formattedDate = "${fecha.year}-${fecha.month}-${fecha.day}";
  await db.collection('animales').add({
    'nombre': nombre,
      'raza': raza,
      'fecha':formattedDate,
      'produccion': null,
      //"Referencias"
      'user': currentUser.uid,
      'finca': finca,
      'lote':null,
      'img': image,
      'state':true,
      'esAdulto':false,
      'esMadre':false,
      'parto':false,
      'idMadre':idMadre
  });
}



Future<void> updateAnimal(String uid, String newNombre, ) async {
  await db.collection('animales').doc(uid).update({
    'nombre': newNombre,
    
  });
}

Future<void> updateAnimalParto(String uid, bool parto,bool esMadre) async {
   DateTime fecha =DateTime.now();
 
 String formattedDate = "${fecha.year}-${fecha.month}-${fecha.day}";
  await db.collection('animales').doc(uid).update({
    'parto': parto,
    'esMadre':esMadre,
    'edadTernero':0,
    'fechaParto':formattedDate
  });
}
Future<void> updateAnimalAdulto(String uid, String rangoEdad) async {
  await db.collection('animales').doc(uid).update({
    'esAdulto': rangoEdad ,
    
  });
}
Future<void> updateAnimalProduccion(String uid, double tproduccion) async {
  await db.collection('animales').doc(uid).update({
    'produccion': tproduccion ,
    
  });
}
Future<void> updateLote(String uid, String lote) async {
  await db.collection('animales').doc(uid).update({
    'lote': lote ,
    
  });
}
Future<void> deleteAnimal(String uid) async {
  
  await db.collection('animales').doc(uid).delete();
}
