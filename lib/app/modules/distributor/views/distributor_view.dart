import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/distributor_controller.dart';
import 'package:intl/intl.dart';
import '../../qr_scanner_page/views/qr_scanner_page_view.dart';

class DistributorView extends StatelessWidget {
  final DistributorController controller = Get.put(DistributorController());

  DistributorView({Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeling Finance'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2F5CA8),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2F5CA8), Color(0xFFF5F6FA)],
              stops: [0.0, 0.3],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchBalance();
              await controller.fetchUserTransactions();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSoldeCard(),
                    const SizedBox(height: 24),
                    _buildServicesGrid(context),
                    const SizedBox(height: 24),
                    _buildTransactionsSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSoldeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solde disponible',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => GestureDetector(
                onTap: controller.toggleAfficherSolde,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.afficherSolde.value
                          ? '${NumberFormat("#,##0", "fr_FR").format(controller.balance.value)} XOF'
                          : '••••••',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F5CA8),
                      ),
                    ),
                    Icon(
                      controller.afficherSolde.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          const Text(
            'Plafond',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                '${NumberFormat("#,##0", "fr_FR").format(controller.plafond.value)} XOF',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F5CA8),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildServiceCard(
          'Retrait',
          Icons.money_off,
          const Color(0xFF4CAF50),
          () => _navigateToQRScanner(context, 'Retrait'),
        ),
        _buildServiceCard(
          'Dépôt',
          Icons.account_balance_wallet,
          const Color(0xFF2196F3),
          () => _navigateToQRScanner(context, 'Dépôt'),
        ),
        _buildServiceCard(
          'Déplafonnement',
          Icons.lock_open,
          const Color(0xFFFFA000),
          () => _navigateToQRScanner(context, 'Déplafonnement'),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transactions récentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.transactions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune transaction',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.transactions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final transaction = controller.transactions[index];
                return _buildTransactionItem(transaction);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isReceived = transaction['receiverId'] == controller.getCurrentUserId();
    final Color color = isReceived ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final String montant = NumberFormat("#,##0", "fr_FR").format(transaction['montant']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isReceived ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['type'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatDate(transaction['date']),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isReceived ? '+' : '-'}$montant XOF',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToQRScanner(BuildContext context, String serviceType) {
    Get.to(() => QRScannerPageView(serviceType: serviceType));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Déconnexion'),
              onPressed: () {
                Navigator.of(context).pop();
                controller.signOut();
              },
            ),
          ],
        );
      },
    );
  }
}