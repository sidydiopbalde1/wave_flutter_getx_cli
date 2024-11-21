      import 'package:cloud_firestore/cloud_firestore.dart';

  class FirestoreService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Méthode pour ajouter un document
    Future<void> addDocument(String collection, Map<String, dynamic> data) async {
      await _firestore.collection(collection).add(data);
    }

    // Méthode pour récupérer les transactions d'un utilisateur spécifique
  Future<List<Map<String, dynamic>>> getUserTransactions(String collection, String userId) async {
    final querySnapshot = await _firestore
        .collection(collection)
        .where('senderId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) => {
          ...doc.data(),
          'id': doc.id, // Inclure l'ID du document
        }).toList();
  }

    // Méthode pour récupérer tous les documents d'une collection
    Future<List<Map<String, dynamic>>> getDocuments(String collection) async {
      final querySnapshot = await _firestore.collection(collection).get();
      return querySnapshot.docs.map((doc) => {
            ...doc.data(),
            'id': doc.id, // Inclure l'ID du document
          }).toList();
    }

    // Méthode pour écouter les documents en temps réel
    Stream<List<Map<String, dynamic>>> listenToDocuments(String collection) {
      return _firestore.collection(collection).snapshots().map((querySnapshot) {
        return querySnapshot.docs.map((doc) => {
              ...doc.data(),
              'id': doc.id, // Inclure l'ID du document
            }).toList();
      });
    }

    // Méthode pour mettre à jour un document
    Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
      await _firestore.collection(collection).doc(docId).update(data);
    }

    // Méthode pour supprimer un document
    Future<void> deleteDocument(String collection, String docId) async {
      await _firestore.collection(collection).doc(docId).delete();
    }

    // Méthode pour récupérer un document spécifique par son ID
  Future<Map<String, dynamic>?> getDocumentById(String collection, String docId) async {
    DocumentSnapshot<Map<String, dynamic>> doc = await _firestore.collection(collection).doc(docId).get();
    if (doc.exists) {
      return {
        ...doc.data()!,
        'id': doc.id, // Inclure l'ID du document
      };
    }
    return null; // Retourne null si le document n'existe pas
  }

  }
