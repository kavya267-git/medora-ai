import 'package:flutter/material.dart';

class MedicalRecordsPage extends StatelessWidget {
  const MedicalRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRecordDialog(context),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecordsSummary(),
            SizedBox(height: 24),
            Text(
              'Recent Records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _RecordsList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medical Record'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Record Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record added successfully!')),
              );
            },
            child: const Text('ADD RECORD'),
          ),
        ],
      ),
    );
  }
}

class _RecordsSummary extends StatelessWidget {
  const _RecordsSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(count: '12', label: 'Total Records'),
          _SummaryItem(count: '3', label: 'This Month'),
          _SummaryItem(count: '5', label: 'Pending'),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String count;
  final String label;

  const _SummaryItem({
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _RecordsList extends StatelessWidget {
  const _RecordsList();

  @override
  Widget build(BuildContext context) {
    final records = [
      _MedicalRecord(
        title: 'Blood Test Report',
        date: '15 Dec 2024',
        type: 'Lab Test',
        status: 'Normal',
        isCritical: false,
      ),
      _MedicalRecord(
        title: 'COVID-19 Test',
        date: '10 Dec 2024',
        type: 'Viral Test',
        status: 'Negative',
        isCritical: false,
      ),
      _MedicalRecord(
        title: 'X-Ray Chest',
        date: '05 Dec 2024',
        type: 'Imaging',
        status: 'Clear',
        isCritical: false,
      ),
      _MedicalRecord(
        title: 'ECG Report',
        date: '01 Dec 2024',
        type: 'Cardiac',
        status: 'Abnormal',
        isCritical: true,
      ),
      _MedicalRecord(
        title: 'Diabetes Checkup',
        date: '25 Nov 2024',
        type: 'Lab Test',
        status: 'Normal',
        isCritical: false,
      ),
    ];

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _RecordCard(record: record);
      },
    );
  }
}

class _MedicalRecord {
  final String title;
  final String date;
  final String type;
  final String status;
  final bool isCritical;

  _MedicalRecord({
    required this.title,
    required this.date,
    required this.type,
    required this.status,
    required this.isCritical,
  });
}

class _RecordCard extends StatelessWidget {
  final _MedicalRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTypeColor(record.type).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(record.type),
            color: _getTypeColor(record.type),
            size: 20,
          ),
        ),
        title: Text(
          record.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: record.isCritical ? Colors.red : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.type),
            Text(record.date, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(record.status),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            record.status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => _showRecordDetails(context, record),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'lab test':
        return Colors.blue;
      case 'viral test':
        return Colors.green;
      case 'imaging':
        return Colors.orange;
      case 'cardiac':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'lab test':
        return Icons.science;
      case 'viral test':
        return Icons.coronavirus;
      case 'imaging':
        return Icons.photo_camera;
      case 'cardiac':
        return Icons.favorite;
      default:
        return Icons.medical_services;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
      case 'negative':
      case 'clear':
        return Colors.green;
      case 'abnormal':
      case 'positive':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showRecordDetails(BuildContext context, _MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${record.type}'),
            Text('Date: ${record.date}'),
            Text('Status: ${record.status}'),
            const SizedBox(height: 16),
            if (record.isCritical)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This result requires medical attention',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record shared!')),
              );
            },
            child: const Text('SHARE'),
          ),
        ],
      ),
    );
  }
}