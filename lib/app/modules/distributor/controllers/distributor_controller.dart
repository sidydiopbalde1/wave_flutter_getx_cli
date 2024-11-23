import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../../services/firebase_store_service.dart';


class DistributorController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();
  final RxDouble totalSent = 0.0.obs;
  final RxDouble totalReceived = 0.0.obs;

  var balance = 0.0.obs; 
  var plafond = 0.0.obs; 
  var isLoading = false.obs; 
  var transactions = <Map<String, dynamic>>[].obs; 
  var afficherSolde = true.obs; 
  var phoneNumber = ''.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchBalance(); 
    fetchPlafond(); 
  }

  // Récupérer le solde utilisateur depuis Firestore
  Future<void> fetchBalance() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      logger.i('Fetching balance for user: ${user?.uid}');

      if (user != null) {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          balance.value = (docSnapshot.data()?['solde'] ?? 0).toDouble();
        } else {
          _showError('Profil utilisateur non trouvé');
        }
      }
    } catch (e) {
      logger.e('Error fetching balance: $e');
      _showError('Impossible de récupérer le solde');
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer le plafond utilisateur depuis Firestore
  Future<void> fetchPlafond() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      logger.i('Fetching plafond for user: ${user?.uid}');

      if (user != null) {
        final docSnapshot =
            await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          plafond.value = (docSnapshot.data()?['plafond'] ?? 0).toDouble();
        } else {
          _showError('Profil utilisateur non trouvé');
        }
      }
    } catch (e) {
      logger.e('Error fetching plafond: $e');
      _showError('Impossible de récupérer le plafond');
    } finally {
      isLoading.value = false;
    }
  }

  // Fonction pour afficher ou masquer le solde
  void toggleAfficherSolde() {
    afficherSolde.value = !afficherSolde.value;
  }

  // Effectuer un retrait en utilisant le numéro de téléphone
 Future<String> effectuerRetrait(double montant, String phoneNumber) async {
    if (isLoading.value) return 'Chargement en cours. Veuillez patienter.';
    print(montant);
    print(phoneNumber);

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return 'Utilisateur non connecté';

      final userSnapshot = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        return 'Utilisateur non trouvé avec ce numéro de téléphone.';
      }

      final userDoc = userSnapshot.docs.first;
      print(userDoc);
      final userData = userDoc.data();
      print(userData);
      final userBalance = (userData['solde'] ?? 0).toDouble();
      print(userBalance);
      if (userBalance < montant) {
        return 'Solde insuffisant pour effectuer le retrait.';
      }

      // Mettre à jour le solde de l'utilisateur cible
      await _firestoreService.updateUserBalance(userDoc.id, userBalance - montant);

      // Mettre à jour le solde de l'utilisateur connecté
      final connectedUserDoc = await _firestoreService.getUserDocument(user.uid);

      final connectedUserBalance = (connectedUserDoc['solde'] ?? 0).toDouble();
      await _firestoreService.updateUserBalance(user.uid, connectedUserBalance + montant);

      // Mettre à jour le solde local
      balance.value = connectedUserBalance + montant;

      // Ajouter la transaction
      await _firestoreService.addDocument('transactions', {
        'date': Timestamp.now(),
        'frais': 0,
        'montant': montant,
        'receiverId': user.uid,
        'recipientName': userData['nom'],
        'senderId': userDoc.id,
        'status': 'completed',
        'type': 'Retrait',
      });

      return 'Retrait effectué avec succès.';
    } catch (e) {
      logger.e('Error performing withdrawal: $e');
      return 'Une erreur est survenue lors du retrait.';
    } finally {
      isLoading.value = false;
    }
  }

  // Effectuer un dépôt en utilisant le numéro de téléphone
  Future<String> effectuerDepot(double montant, String phoneNumber) async {
    if (isLoading.value) return 'Chargement en cours. Veuillez patienter.';
    print(montant);
    print(phoneNumber);

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return 'Utilisateur non connecté';

      final userSnapshot = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
    print(userSnapshot);
      if (userSnapshot.docs.isEmpty) {
        return 'Utilisateur non trouvé avec ce numéro de téléphone.';
      }

      final userDoc = userSnapshot.docs.first;
      print(userDoc);
      final userData = userDoc.data();
      print(userData);
      final userPlafond = (userData['plafond'] ?? 0).toDouble();
      print(userPlafond);
      final userBalance = (userData['solde'] ?? 0).toDouble();
      print(userBalance);

      // if (userBalance + montant > userPlafond) {
      //   return 'Plafond dépassé. Vous ne pouvez pas déposer ce montant.';
      // }

      // Mettre à jour le solde de l'utilisateur cible
      await _firestoreService.updateUserBalance(userDoc.id, userBalance + montant);

      // Mettre à jour le solde de l'utilisateur connecté
      final connectedUserDoc = await _firestoreService.getUserDocument(user.uid);
      print(connectedUserDoc);
      final connectedUserBalance = (connectedUserDoc['solde'] ?? 0).toDouble();
      print(connectedUserBalance);
      await _firestoreService.updateUserBalance(user.uid, connectedUserBalance - montant);

      // Mettre à jour le solde local
      balance.value = connectedUserBalance - montant;
      print(balance.value);

      // Ajouter la transaction
      await _firestoreService.addDocument('transactions', {
        'date': Timestamp.now(),
        'frais': 0,
        'montant': montant,
        'receiverId': user.uid,
        'recipientName': userData['nom'],
        'senderId': userDoc.id,
        'status': 'completed',
        'type': 'Dépôt',
      });

      return 'Dépôt effectué avec succès.';
    } catch (e) {
      logger.e('Error performing deposit: $e');
      return 'Une erreur est survenue lors du dépôt.';
    } finally {
      isLoading.value = false;
    }
  }

  // Déplafonner l'utilisateur (ajuster son plafond) en fonction du numéro de téléphone
    Future<String> deplafonnerUtilisateur(double montant, String phoneNumber) async {
    if (isLoading.value) return 'Chargement en cours. Veuillez patienter.';
    print(montant);
    print(phoneNumber);

    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return 'Utilisateur non connecté';

      final userSnapshot = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      print(userSnapshot);
      if (userSnapshot.docs.isEmpty) {
        return 'Utilisateur non trouvé avec ce numéro de téléphone.';
      }

      final userDoc = userSnapshot.docs.first;
      print(userDoc);
      final userData = userDoc.data();
      print(userData);
      final userPlafond = userData['plafond'];


      // Mettre à jour le plafond dans Firestore
      await _firestoreService.updateDocument('users', userDoc.id, {
        'plafond': userPlafond + montant,
      });

      // Ajouter la transaction
      await _firestoreService.addDocument('transactions', {
        'date': Timestamp.now(),
        'frais': 0,
        'montant': montant,
        'receiverId': userDoc.id,
        'senderId': user.uid,
        'type': 'Déplafonnement',
        'status': 'completed',
      });

      return 'Déplafonnement effectué avec succès.';
    } catch (e) {
      logger.e('Error performing deplafonnement: $e');
      return 'Une erreur est survenue lors du déplafonnement.';
    } finally {
      isLoading.value = false;
    }
  }

  // Ajouter une transaction à la liste
  // void _addTransaction(String type, double montant) {
  //   transactions.insert(0, {
  //     'type': type,
  //     'montant': montant.toString(),
  //     'date': DateTime.now().toIso8601String(),
  //   });
  // }

  // Afficher une erreur
  void _showError(String message) {
    Get.snackbar('Erreur', message,
        snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3));
  }
    Future<void> fetchUserTransactions() async {
  try {
    isLoading.value = true;
    final user = _auth.currentUser;

    if (user != null) {
      final QuerySnapshot transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      // Traitement des transactions
      _processTransactions(transactionsSnapshot, user.uid);
    }
  } catch (e) {
    logger.e('Erreur lors de la récupération des transactions: $e');
    _showError('Impossible de récupérer vos transactions');
  } finally {
    isLoading.value = false;
  }
}

void _processTransactions(QuerySnapshot snapshot, String userId) {
  final fetchedTransactions = snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Conversion de 'date' en Timestamp et puis en DateTime
    final Timestamp timestamp = data['date'] as Timestamp;
    final DateTime dateTime = timestamp.toDate();

    return {
      ...data,
      'id': doc.id, // Ajouter l'identifiant du document
      'date': dateTime, // Utiliser le format DateTime pour plus de flexibilité
      'isSender': data['senderId'] == userId, // Vérifier si l'utilisateur est l'expéditeur
    };
  }).toList();

  // Mettre à jour les transactions localement
  transactions.value = fetchedTransactions;
}

  void _calculateTotals(List<Map<String, dynamic>> transactionsList, String senderId) {
    totalSent.value = transactionsList
        .where((t) => t['senderId'] == senderId)
        .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));

    totalReceived.value = transactionsList
        .where((t) => t['receiverId'] == senderId)
        .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));
  }
}
