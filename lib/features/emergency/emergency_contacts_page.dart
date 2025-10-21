import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  List<EmergencyContact> _contacts = [];
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _relationshipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // Load contacts from shared preferences
  Future<void> _loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString('emergency_contacts');
      
      if (contactsJson != null) {
        final List<dynamic> contactsList = json.decode(contactsJson) as List<dynamic>;
        setState(() {
          _contacts = contactsList.map<EmergencyContact>((contact) => 
            EmergencyContact.fromJson(contact as Map<String, dynamic>)
          ).toList();
        });
      } else {
        // Add default system contacts if no saved contacts
        setState(() {
          _contacts = [
            EmergencyContact(name: 'Ambulance', number: '108', isSystem: true),
            EmergencyContact(name: 'Police', number: '100', isSystem: true),
            EmergencyContact(name: 'Fire Department', number: '101', isSystem: true),
          ];
        });
      }
    } catch (e) {
      // Initialize with default contacts on error
      setState(() {
        _contacts = [
          EmergencyContact(name: 'Ambulance', number: '108', isSystem: true),
          EmergencyContact(name: 'Police', number: '100', isSystem: true),
          EmergencyContact(name: 'Fire Department', number: '101', isSystem: true),
        ];
      });
    }
  }

  // Save contacts to shared preferences
  Future<void> _saveContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = json.encode(
        _contacts.map((contact) => contact.toJson()).toList()
      );
      await prefs.setString('emergency_contacts', contactsJson);
    } catch (e) {
      // Handle error silently in production
    }
  }

  void _addContact() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name*',
                hintText: 'e.g., John Doe',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number*',
                hintText: 'e.g., +91 9876543210',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                hintText: 'e.g., Father, Friend, Doctor',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '* Required fields',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _numberController.clear();
              _relationshipController.clear();
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty && 
                  _numberController.text.trim().isNotEmpty) {
                setState(() {
                  _contacts.add(EmergencyContact(
                    name: _nameController.text.trim(),
                    number: _numberController.text.trim(),
                    relationship: _relationshipController.text.trim().isEmpty 
                        ? null 
                        : _relationshipController.text.trim(),
                    isSystem: false,
                  ));
                });
                _saveContacts(); // Save to persistent storage
                _nameController.clear();
                _numberController.clear();
                _relationshipController.clear();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency contact added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('ADD CONTACT'),
          ),
        ],
      ),
    );
  }

  void _deleteContact(int index) {
    if (!_contacts[index].isSystem) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Contact'),
          content: Text('Are you sure you want to delete ${_contacts[index].name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  _contacts.removeAt(index);
                });
                _saveContacts(); // Save to persistent storage
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact removed'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void _editContact(int index) {
    if (_contacts[index].isSystem) return;
    
    _nameController.text = _contacts[index].name;
    _numberController.text = _contacts[index].number;
    _relationshipController.text = _contacts[index].relationship ?? '';

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name*',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number*',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '* Required fields',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              _numberController.clear();
              _relationshipController.clear();
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty && 
                  _numberController.text.trim().isNotEmpty) {
                setState(() {
                  _contacts[index] = EmergencyContact(
                    name: _nameController.text.trim(),
                    number: _numberController.text.trim(),
                    relationship: _relationshipController.text.trim().isEmpty 
                        ? null 
                        : _relationshipController.text.trim(),
                    isSystem: false,
                  );
                });
                _saveContacts(); // Save to persistent storage
                _nameController.clear();
                _numberController.clear();
                _relationshipController.clear();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addContact,
            tooltip: 'Add Contact',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'These contacts will be notified automatically when you trigger Emergency SOS. '
                  'System contacts cannot be edited or removed.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Contacts List
          Expanded(
            child: _contacts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.contacts, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No emergency contacts yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first contact',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: contact.isSystem 
                                  ? const Color(0xFFE3F2FD)
                                  : const Color(0xFFE8F5E8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              contact.isSystem ? Icons.security : Icons.person,
                              color: contact.isSystem ? Colors.blue : Colors.green,
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contact.number),
                              if (contact.relationship != null && 
                                  contact.relationship!.isNotEmpty)
                                Text(
                                  contact.relationship!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (contact.isSystem)
                                const Text(
                                  'System Contact',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          trailing: contact.isSystem
                              ? null
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editContact(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteContact(index),
                                    ),
                                  ],
                                ),
                          onTap: contact.isSystem ? null : () => _editContact(index),
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

class EmergencyContact {
  final String name;
  final String number;
  final String? relationship;
  final bool isSystem;

  EmergencyContact({
    required this.name,
    required this.number,
    this.relationship,
    required this.isSystem,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'relationship': relationship,
      'isSystem': isSystem,
    };
  }

  // Create from JSON
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String,
      number: json['number'] as String,
      relationship: json['relationship'] as String?,
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }
}