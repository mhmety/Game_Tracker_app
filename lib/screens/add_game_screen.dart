import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AddGameScreen extends StatelessWidget {
  const AddGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Game')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Game Title'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await firestore.addGame(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            )
          ],
        ),
      ),
    );
  }
}
