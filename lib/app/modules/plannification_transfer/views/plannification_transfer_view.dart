// scheduled_transaction_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/plannification_transfer_controller.dart';

class PlannificationTransferView extends StatelessWidget {
  final PlannificationTransferController controller = Get.put(PlannificationTransferController());

  PlannificationTransferView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planifier un transfert'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipientField(),
              const SizedBox(height: 20),
              _buildAmountField(),
              const SizedBox(height: 20),
              _buildDateTimePicker(context),
              const SizedBox(height: 20),
              _buildFrequencySelector(),
              const SizedBox(height: 30),
              _buildScheduleButton(),
              const SizedBox(height: 30),
              _buildScheduledTransactionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Numéro du destinataire',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.recipientController,
          decoration: InputDecoration(
            hintText: 'Ex: 785304869',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Montant',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.amountController,
          decoration: InputDecoration(
            hintText: 'Montant en FCFA',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: const Icon(Icons.attach_money),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date et heure prévues',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => controller.selectDateTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Obx(() => Text(
                      controller.selectedDateTime.value != null
                          ? DateFormat('dd/MM/yyyy HH:mm')
                              .format(controller.selectedDateTime.value!)
                          : 'Sélectionner date et heure',
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fréquence de répétition',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedFrequency.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.repeat),
              ),
              items: [
                'Ponctuel',
                'Journalier', 
                'Hebdomadaire', 
                'Mensuel', 
                'Annuel'
              ].map((String frequency) {
                return DropdownMenuItem<String>(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (String? newValue) {
                controller.selectedFrequency.value = newValue!;
              },
            )),
      ],
    );
  }

  Widget _buildScheduleButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
            onPressed: controller.isProcessing.value
                ? null
                : () => controller.scheduleTransaction(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: controller.isProcessing.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Planifier le transfert',
                    style: TextStyle(fontSize: 16),
                  ),
          )),
    );
  }

  Widget _buildScheduledTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transferts planifiés',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.scheduledTransactions.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun transfert planifié',
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
            itemCount: controller.scheduledTransactions.length,
            itemBuilder: (context, index) {
              final transaction = controller.scheduledTransactions[index];
              return _buildScheduledTransactionItem(transaction);
            },
          );
        }),
      ],
    );
  }

  Widget _buildScheduledTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.schedule, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pour: ${transaction['recipientName']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction['montant'].toString()} FCFA',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prévu: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction['date'].toDate())}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fréquence: ${transaction['frequency']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => controller.cancelScheduledTransaction(transaction['id']),
          ),
        ],
      ),
    );
  }
}