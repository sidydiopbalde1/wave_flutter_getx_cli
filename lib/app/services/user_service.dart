import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Vérifie si un utilisateur existe avec un numéro de téléphone
  Future<bool> userExistsByPhone(String phoneNumber) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection('users')
          .where('telephone', isEqualTo: phoneNumber)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
