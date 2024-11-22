import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../transaction/views/transaction_view.dart';
import 'package:intl/intl.dart';

class ActionItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  ActionItem(this.title, this.icon, this.onTap);
}

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 16),
                  _buildTransactionSummary(),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 16),
                  _buildTransactionsList(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Feeling Finance',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: controller.signOut,
        ),
      ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      controller.isBalanceVisible.value
                          ? '${controller.balance.value.toStringAsFixed(2)} FCFA'
                          : '••••••',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                IconButton(
                  icon: Obx(() => Icon(
                        controller.isBalanceVisible.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      )),
                  onPressed: controller.toggleBalanceVisibility,
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
            '$amount FCFA',
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
            // Logic for "Recevoir"
          }),
          _buildActionButton('Historique', Icons.history, () {
            Get.to(() => TransactionView());
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
          CircleAvatar(
            backgroundColor: Colors.blue[500],
            child: Icon(icon, color: Colors.white),
            radius: 30,
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Obx(() {
      if (controller.transactions.isEmpty) {
        return const Center(child: Text('Aucune transaction.'));
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.transactions.length,
        itemBuilder: (context, index) {
          final transaction = controller.transactions[index];

          // Parse la date qui est au format String
          final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
          final DateTime transactionDate = DateTime.parse(transaction['date'].toString());
          final String formattedDate = dateFormat.format(transactionDate);

          return _buildTransactionItem(transaction, formattedDate);
        },
      );
    });
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, String formattedDate) {
    final bool isSender = transaction['senderId'] != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
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
        child: Row(
          children: [
            // Icône de transaction
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSender ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSender ? Icons.arrow_upward : Icons.arrow_downward,
                color: isSender ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            // Détails de la transaction
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${transaction['montant'].toStringAsFixed(2)} FCFA',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Le $formattedDate',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
