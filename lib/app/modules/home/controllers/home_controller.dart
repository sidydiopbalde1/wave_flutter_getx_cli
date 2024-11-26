import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_pages.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  // Instances Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final logger = Logger();

  // Variables réactives
  final RxBool isBalanceVisible = true.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble totalSent = 0.0.obs;
  final RxDouble totalReceived = 0.0.obs;
  final RxString userPhone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchBalance(),
        fetchUserTransactions(),
        fetchUserPhone(),
      ]);
    } catch (e) {
      logger.e('Erreur lors de l\'initialisation: $e');
      _showError('Erreur lors du chargement des données');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBalanceVisibility() => isBalanceVisible.toggle();

  Future<void> fetchBalance() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        logger.i('Fetching balance for user: ${user.uid}');

        _firestore.collection('users').doc(user.uid).snapshots().listen(
          (docSnapshot) {
            if (docSnapshot.exists) {
              balance.value = (docSnapshot.data()?['solde'] ?? 0).toDouble();
            } else {
              logger.w('Profil utilisateur non trouvé');
            }
          },
          onError: (e) {
            logger.e('Erreur dans le stream du solde: $e');
            _showError('Erreur de mise à jour du solde');
          },
        );
      }
    } catch (e) {
      logger.e('Erreur lors de la récupération du solde: $e');
      _showError('Impossible de récupérer le solde');
    }
  }

  Future<void> fetchUserPhone() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
        if (docSnapshot.exists) {
          userPhone.value = docSnapshot.data()?['telephone'] ?? '';
          logger.i('Numéro de téléphone récupéré: ${userPhone.value}');
        }
      }
    } catch (e) {
      logger.e('Erreur lors de la récupération du numéro de téléphone: $e');
      _showError('Erreur lors de la récupération du numéro de téléphone');
    }
  }

  String getUserQRData() {
    try {
      final user = _auth.currentUser;
      if (user != null && userPhone.value.isNotEmpty) {
        final Map<String, String> userData = {
          'userId': user.uid,
          'telephone': userPhone.value,
        };
        return userData.toString();
      }
      return '';
    } catch (e) {
      logger.e('Erreur lors de la génération des données QR: $e');
      return '';
    }
  }

  Future<void> fetchUserTransactions() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        logger.i('Fetching transactions for user: ${user.uid}');

        _firestore
            .collection('transactions')
            .where(Filter.or(
            Filter('senderId', isEqualTo: user.uid),
            Filter('receiverId', isEqualTo: user.uid),
            ))
            .orderBy('date', descending: true)
            .snapshots()
            .listen(
          (querySnapshot) {
            _processTransactions(querySnapshot, user.uid);
          },
          onError: (e) {
            logger.e('Erreur dans le stream des transactions: $e');
            _showError('Erreur de mise à jour des transactions');
          },
        );
      }
    } catch (e) {
      logger.e('Erreur lors de la récupération des transactions: $e');
      _showError('Impossible de récupérer vos transactions');
    }
  }

  void _processTransactions(QuerySnapshot snapshot, String userId) {
    try {
      final fetchedTransactions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final Timestamp timestamp = data['date'] as Timestamp;
        final DateTime dateTime = timestamp.toDate();

        return {
          'id': doc.id,
          'senderId': data['senderId'],
          'receiverId': data['receiverId'],
          'montant': data['montant'],
          'recipientName': data['recipientName'],
          'date': dateTime,
          'status': data['status'] ?? 'completed',
        };
      }).toList();

      transactions.assignAll(fetchedTransactions);
      _calculateTotals(fetchedTransactions, userId);
      logger.d('Transactions mises à jour: ${transactions.length} transactions');
    } catch (e) {
      logger.e('Erreur lors du traitement des transactions: $e');
    }
  }

  void _calculateTotals(List<Map<String, dynamic>> transactionsList, String userId) {
    try {
      totalSent.value = transactionsList
          .where((t) => 
              t['senderId'] == userId && 
              t['status'] != 'cancelled')
          .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));

      totalReceived.value = transactionsList
          .where((t) => 
              t['receiverId'] == userId && 
              t['status'] != 'cancelled')
          .fold(0.0, (sum, t) => sum + (t['montant'] ?? 0.0));
    } catch (e) {
      logger.e('Erreur lors du calcul des totaux: $e');
    }
  }

  bool canCancelTransaction(dynamic transactionDate) {
    print(transactionDate);
    // Vérifier que transactionDate peut être converti en DateTime
    if (transactionDate is DateTime) {
      // Convertir la date de la transaction en DateTime
      final DateTime transactionDateTime = transactionDate;
      // Calculer la différence entre maintenant et la date de la transaction
      final Duration difference = DateTime.now().difference(transactionDateTime);
      print(difference.inMinutes <= 30);
      // Vérifier si la différence est inférieure ou égale à 30 minutes
      return difference.inMinutes <= 30;
    }
    // Retourne faux si transactionDate n'est pas du type attendu
    return false;
  }



  Future<void> cancelTransaction(String transactionId) async {
    try {
      isLoading.value = true;
      print(transactionId);
      // Récupérer les détails de la transaction
      final transactionDoc = await _firestore
          .collection('transactions')
          .doc(transactionId)
          .get();
      print(transactionDoc);
      if (!transactionDoc.exists) {
        throw 'Transaction non trouvée';
      }

      final transactionData = transactionDoc.data()!;
      print(transactionData);
      
      if (transactionData['status'] == 'cancelled') {
        throw 'Cette transaction est déjà annulée';
      }

      final DateTime transactionDate = (transactionData['date'] ).toDate();

      // Vérifier si la transaction peut être annulée (moins de 30 minutes)
      if (!canCancelTransaction(transactionDate)) {
        throw 'Cette transaction ne peut plus être annulée (délai de 30 minutes dépassé)';
      }

      // Commencer une transaction Firestore
      await _firestore.runTransaction((transaction) async {
        // Vérifier les soldes et effectuer les transferts
        final senderDoc = _firestore
            .collection('users')
            .doc(transactionData['senderId']);
            print(senderDoc);
        final receiverDoc = _firestore
            .collection('users')
            .doc(transactionData['receiverId']);
            print(receiverDoc);

        final senderSnapshot = await transaction.get(senderDoc);
        print(senderSnapshot);
        final receiverSnapshot = await transaction.get(receiverDoc);
        print(receiverSnapshot);
        if (!senderSnapshot.exists || !receiverSnapshot.exists) {
          throw 'Utilisateur non trouvé';
        }

        final double currentSenderBalance = senderSnapshot.data()!['solde'] ?? 0.0;
        final double currentReceiverBalance = receiverSnapshot.data()!['solde'] ?? 0.0;
        final double amount = transactionData['montant'];

        if (currentReceiverBalance < amount) {
          throw 'Le destinataire ne dispose pas de fonds suffisants pour l\'annulation';
        }

        // Mettre à jour les soldes
        transaction.update(senderDoc, {
          'solde': currentSenderBalance + amount
        });
        transaction.update(receiverDoc, {
          'solde': currentReceiverBalance - amount
        });

        // Marquer la transaction comme annulée
        transaction.update(
          transactionDoc.reference,
          {
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp(),
          },
        );
      });

      Get.snackbar(
        'Succès',
        'La transaction a été annulée avec succès',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      await refreshData();
    } catch (e) {
      logger.e('Erreur lors de l\'annulation de la transaction: $e');
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      logger.e('Error signing out: $e');
      _showError('Échec de la déconnexion');
    }
  }

  Future<void> refreshData() async {
    await _initializeData();
  }

  void _showError(String message) {
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
    );
  }

  // Getters
  int get transactionCount => transactions.length;
}