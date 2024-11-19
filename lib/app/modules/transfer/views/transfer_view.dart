import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/transfer_controller.dart';

class TransferView extends GetView<TransferController> {
  const TransferView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TransferView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TransferView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
