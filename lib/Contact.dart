import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<Map<String, String>> contacts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Mes Contacts"),
        backgroundColor: Colors.purple,
      ),
      body: contacts.isEmpty
          ? const Center(
        child: Text(
          "Aucun contact pour le moment\nAjoutez-en un !",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple,
                child: Text(
                  contact['nom']![0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text("${contact['prenom']} ${contact['nom']}"),
              subtitle: Text("${contact['email']} • ${contact['numero']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddEditContactPage(
                                onSave: (newContact) {
                                  setState(() {
                                    contacts[index] = newContact;
                                  });
                                },
                                contact: contact,
                              )));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => contacts.removeAt(index));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddEditContactPage(
                    onSave: (newContact) {
                      setState(() {
                        contacts.add(newContact);
                      });
                    },
                  )));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditContactPage extends StatefulWidget {
  final Function(Map<String, String>) onSave;
  final Map<String, String>? contact;

  const AddEditContactPage({super.key, required this.onSave, this.contact});

  @override
  State<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage> {
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController emailController;
  late TextEditingController numeroController;

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.contact?['nom']);
    prenomController = TextEditingController(text: widget.contact?['prenom']);
    emailController = TextEditingController(text: widget.contact?['email']);
    numeroController = TextEditingController(text: widget.contact?['numero']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? "Ajouter un contact" : "Modifier le contact"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: prenomController,
              decoration: const InputDecoration(
                  labelText: "Prénom", prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                  labelText: "Nom", prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: "Email", prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numeroController,
              decoration: const InputDecoration(
                  labelText: "Téléphone", prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final newContact = {
                  'nom': nomController.text,
                  'prenom': prenomController.text,
                  'email': emailController.text,
                  'numero': numeroController.text,
                };
                widget.onSave(newContact);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              child: const Text("Enregistrer",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}