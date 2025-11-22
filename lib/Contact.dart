import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'Login.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> filteredContacts = [];

  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    loadContacts();
    searchController.addListener(_filterContacts);
  }

  Future<void> _loadUserEmail() async {
    final email = await DatabaseHelper.instance.getLoggedInEmail();
    setState(() {
      userEmail = email;
    });
  }

  Future<void> loadContacts() async {
    final data = await DatabaseHelper.instance.getContacts();
    setState(() {
      contacts = data;
      filteredContacts = data;
    });
  }

  void _filterContacts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts.where((c) {
        final name = c['name'].toString().toLowerCase();
        final phone = c['phone'].toString().toLowerCase();
        return name.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  void _showContactDialog({Map<String, dynamic>? contact}) {
    if (contact != null) {
      nameController.text = contact['name'];
      phoneController.text = contact['phone'];
    } else {
      nameController.clear();
      phoneController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          contact == null ? "Ajouter un contact" : "Modifier le contact",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Téléphone"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isEmpty || phone.isEmpty) return;

              if (contact == null) {
                await DatabaseHelper.instance.insertContact({
                  "name": name,
                  "phone": phone,
                });
              } else {
                await DatabaseHelper.instance.updateContact(contact['id'], {
                  "name": name,
                  "phone": phone,
                });
              }
              loadContacts();
              Navigator.pop(context);
            },
            child: Text(contact == null ? "Ajouter" : "Modifier"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteContact(int id) async {
    await DatabaseHelper.instance.deleteContact(id);
    loadContacts();
  }

  // --- BOUTON DECONNEXION ---
  Future<void> _logout() async {
    // Supprime l'utilisateur connecté
    await DatabaseHelper.instance.setLoggedInEmail(null);

    // Redirige vers LoginPage et supprime toute l'historique
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Contacts - ${userEmail ?? ''}"),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Déconnexion",
            onPressed: _logout, // ATTENTION: pas de parenthèses
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactDialog(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // RECHERCHE
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un contact...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.purple.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // LISTE DES CONTACTS
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final c = filteredContacts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(c['name'][0].toUpperCase()),
                    ),
                    title: Text(c['name']),
                    subtitle: Text(c['phone']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showContactDialog(contact: c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteContact(c['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
