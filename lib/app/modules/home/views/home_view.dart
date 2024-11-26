import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'qrcode_modal.dart';
import '../controllers/home_controller.dart';
import 'package:intl/intl.dart'; // Pour la gestion de la date
import '../../transaction/views/transaction_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../plannification_transfer/views/plannification_transfer_view.dart';

class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page d\'accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Appel de la méthode de déconnexion
              controller.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              _buildBalanceCard(),
              const SizedBox(height: 20),
              _buildTransactionSummary(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.blue[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solde disponible',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => Text(
                                  controller.isBalanceVisible.value
                                      ? '${controller.balance.value.toStringAsFixed(2)} FCFA'
                                      : '••••••',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ),
                          IconButton(
                            icon: Obx(() => Icon(
                                  controller.isBalanceVisible.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white,
                                )),
                            onPressed: controller.toggleBalanceVisibility,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.qr_code,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Get.dialog(
                                QRCodeModal(
                                  qrCodeData: controller.userPhone.value,  // Passer le téléphone ici
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Envoyé',
              controller.totalSent.value,
              Icons.arrow_upward,
              Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Reçu',
              controller.totalReceived.value,
              Icons.arrow_downward,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(2)} FCFA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton('Envoyer', Icons.send, () {
            Get.to(() => TransactionView());
          }),
          _buildActionButton('Recevoir', Icons.arrow_downward, () {
            Get.dialog(
              QRCodeModal(
                qrCodeData: controller.getUserQRData(),
              ),
            );
          }),
          _buildActionButton('Plannifier', Icons.schedule, () {
             Get.to(() => PlannificationTransferView());
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[500],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildTransactionsList() {
    return Obx(() {
      if (controller.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune transaction',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.transactions.length,
        itemBuilder: (context, index) {
          final transaction = controller.transactions[index];
          final date = _getTransactionDate(transaction['date']);
          final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
          return _buildTransactionItem(transaction, formattedDate);
        },
      );
    });
  }

DateTime _getTransactionDate(dynamic date) {
  if (date is Timestamp) {
    return date.toDate(); // Appeler toDate uniquement si c'est un Timestamp
  } else if (date is DateTime) {
    return date; // Retourner directement si c'est un DateTime
  } else if (date is String) {
    // Si c'est une chaîne, tenter de la parser
    return DateTime.parse(date);
  } else {
    // Fallback: Retourner la date actuelle si le type est inconnu
    return DateTime.now();
  }
}


  Widget _buildTransactionItem(Map<String, dynamic> transaction, String formattedDate) {
    final bool isSender = transaction['senderId'] == _auth.currentUser?.uid;
    print('isSender $isSender');
    final dynamic transactionDate = _getTransactionDate(transaction['date']);
    
    final bool canCancel = controller.canCancelTransaction(transactionDate) &&
        isSender &&
        (transaction['status'] != 'cancelled');
  print('ANNULATION: $canCancel');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: transaction['status'] == 'cancelled'
              ? Border.all(color: Colors.red.withOpacity(0.5))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[300],
              radius: 25,
              child: Icon(
                isSender ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isSender ? 'Envoyé à' : 'Reçu de'} ${transaction['recipientName']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(formattedDate),
                ],
              ),
            ),
            if (canCancel)
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  controller.cancelTransaction(transaction['id']);
                },
              ),
          ],
        ),
      ),
    );
  }
}
