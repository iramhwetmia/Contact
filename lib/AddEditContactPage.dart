import 'package:flutter/material.dart';

class AddEditContactPage extends StatefulWidget {
  final Map<String, dynamic>? contact;
  final Function(Map<String, dynamic>) onSave;

  const AddEditContactPage({super.key, this.contact, required this.onSave});

  @override
  State<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage> {
  late TextEditingController prenomController;
  late TextEditingController nomController;
  late TextEditingController emailController;
  late TextEditingController numeroController;

  @override
  void initState() {
    super.initState();
    prenomController = TextEditingController(text: widget.contact?['prenom']);
    nomController = TextEditingController(text: widget.contact?['nom']);
    emailController = TextEditingController(text: widget.contact?['email']);
    numeroController = TextEditingController(text: widget.contact?['numero']);
  }

  @override
  void dispose() {
    prenomController.dispose();
    nomController.dispose();
    emailController.dispose();
    numeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contact == null ? "Ajouter un contact" : "Modifier le contact",
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: prenomController,
              decoration: const InputDecoration(labelText: "Prénom"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numeroController,
              decoration: const InputDecoration(labelText: "Téléphone"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final newContact = {
                  'id': widget.contact?['id'],
                  'prenom': prenomController.text,
                  'nom': nomController.text,
                  'email': emailController.text,
                  'numero': numeroController.text,
                };

                widget.onSave(newContact);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text(
                "Enregistrer",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
