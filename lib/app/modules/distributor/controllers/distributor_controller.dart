import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import '../../../services/firebase_store_service.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/transactionModel.dart';

class DistributorController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();
  final RxDouble totalSent = 0.0.obs;
  final RxDouble totalReceived = 0.0.obs;
    final message = ''.obs;
      final montantController = TextEditingController();
    final formKey = GlobalKey<FormState>();

  var balance = 0.0.obs;
  var plafond = 0.0.obs;
  var isLoading = false.obs;
  var transactions = <Map<String, dynamic>>[].obs;
  var afficherSolde = true.obs;
  var phoneNumber = ''.obs;
  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  StreamSubscription<QuerySnapshot>? _transactionsSubscription;

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  @override
  void onInit() {
    super.onInit();
    setupRealtimeListeners();
    fetchBalance();
    fetchPlafond();
    fetchUserTransactions();
  }

  @override
  void onClose() {
    _balanceSubscription?.cancel();
    _transactionsSubscription?.cancel();
     montantController.dispose();
    super.onClose();
  }

  void setupRealtimeListeners() {
    final user = _auth.currentUser;
    if (user != null) {
      // Écoute en temps réel du solde
      _balanceSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          balance.value = (snapshot.data()?['solde'] ?? 0).toDouble();
          plafond.value = (snapshot.data()?['plafond'] ?? 0).toDouble();
        }
      });

      // Écoute en temps réel des transactions
      _transactionsSubscription = _firestore
          .collection('transactions')
          .where(Filter.or(
            Filter('senderId', isEqualTo: user.uid),
            Filter('receiverId', isEqualTo: user.uid),
          ))
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        _processTransactions(snapshot, user.uid);
      });
    }
  }

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
          showMessage('Erreur', 'Profil utilisateur non trouvé');
        }
      }
    } catch (e) {
      logger.e('Error fetching balance: $e');
      showMessage('Erreur', 'Impossible de récupérer le solde');
    } finally {
      isLoading.value = false;
    }
  }

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
          showMessage('Erreur', 'Profil utilisateur non trouvé');
        }
      }
    } catch (e) {
      logger.e('Error fetching plafond: $e');
      showMessage('Erreur', 'Impossible de récupérer le plafond');
    } finally {
      isLoading.value = false;
    }
  }

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

      // Mettre à jour le solde localy*yy
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

  void showMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: title == 'Succès' ? Colors.green : Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: Icon(
        title == 'Succès' ? Icons.check_circle : Icons.error,
        color: Colors.white,
      ),
    );
  }

  Future<void> fetchUserTransactions() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;

      if (user != null) {
        final QuerySnapshot transactionsSnapshot = await _firestore
            .collection('transactions')
            .where(Filter.or(
              Filter('senderId', isEqualTo: user.uid),
              Filter('receiverId', isEqualTo: user.uid),
            ))
            .orderBy('date', descending: true)
            .get();

        _processTransactions(transactionsSnapshot, user.uid);
      }
    } catch (e) {
      logger.e('Erreur lors de la récupération des transactions: $e');
      showMessage('Erreur', 'Impossible de récupérer vos transactions');
    } finally {
      isLoading.value = false;
    }
  }

  void _processTransactions(QuerySnapshot snapshot, String userId) {
    final fetchedTransactions = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final Timestamp timestamp = data['date'] as Timestamp;
      final DateTime dateTime = timestamp.toDate();

      return {
        ...data,
        'id': doc.id,
        'date': dateTime,
        'isSender': data['senderId'] == userId,
      };
    }).toList();

    transactions.value = fetchedTransactions;
    _calculateTotals(fetchedTransactions, userId);
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      showMessage('Succès', 'Déconnexion réussie');
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      logger.e('Error signing out: $e');
      showMessage('Erreur', 'Échec de la déconnexion');
    }
  }

  void _calculateTotals(List<Map<String, dynamic>> transactionsList, String userId) {
    totalSent.value = transactionsList
        .where((t) => t['senderId'] == userId)
        .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));

    totalReceived.value = transactionsList
        .where((t) => t['receiverId'] == userId)
        .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));
  }

  Future<void> processTransaction({
    required String serviceType,
    required String phoneNumber,
    required int montant,
  }) async {
    try {
      isLoading.value = true;
      
      // Vérifier si l'utilisateur est connecté
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Récupérer le document utilisateur pour vérifier le solde
      final userDoc = await _firestoreService.getUserDocument(userId);
      final currentBalance = userDoc['solde'] ?? 0.0;
      
      double newBalance = currentBalance;
      String transactionType = serviceType.toLowerCase();
      double frais = 0.0;

      // Calculer les frais et le nouveau solde selon le type d'opération
      switch (serviceType.toLowerCase()) {
        case 'retrait':
          frais = montant * 0.02; // 2% de frais pour le retrait
          if (montant + frais > currentBalance) {
            throw Exception('Solde insuffisant pour effectuer le retrait');
          }
          newBalance = currentBalance - (montant + frais);
          break;

        case 'dépôt':
          frais = montant * 0.01; // 1% de frais pour le dépôt
          newBalance = currentBalance + montant - frais;
          break;

        case 'déplafonnement':
          // Logique spécifique pour le déplafonnement
          // Par exemple, vérifier si le montant demandé est valide
          if (montant <= userDoc['plafond']) {
           message.value='Le nouveau plafond doit être supérieur au plafond actuel';
          }
           await _firestoreService.updateDocument('users', userDoc.id, {
            'plafond': userDoc['plafond'] + montant,
           });
          transactionType = 'déplafonnement';
          break;

        default:
          throw Exception('Type d\'opération non reconnu');
      }

      // Mettre à jour le solde si ce n'est pas un déplafonnement
      if (serviceType.toLowerCase() != 'déplafonnement') {
        await _firestoreService.updateUserBalance(userId, newBalance);
      }

      // Créer la transaction
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: transactionType,
        montant: montant.toDouble(),
        date: Timestamp.now(),
        recipientName: phoneNumber, // Utiliser le numéro de téléphone comme nom du destinataire
        senderId: userId,
        receiverId: phoneNumber,
        status: 'completed',
        frais: frais,
      );

      // Enregistrer la transaction
      await _firestoreService.addDocument('transactions', transaction.toFirestore());

      message.value = 'Opération effectuée avec succès';
    } catch (e) {
      message.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
    void updateMessage(String newMessage) {
    message.value = newMessage;
  }

}