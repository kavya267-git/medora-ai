import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  List<String> _symptoms = [];

  void _searchSymptoms() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    final snapshot = await _firestore
        .collection('symptoms') // Your collection name
        .where('name', isEqualTo: query)
        .get();

    setState(() {
      _symptoms = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Enter symptom",
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchSymptoms,
              child: const Text("Search"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _symptoms.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_symptoms[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
