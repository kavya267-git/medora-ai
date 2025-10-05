import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

class DashboardPage extends StatelessWidget {
  final String userRole;

  const DashboardPage({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medora Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    switch (userRole) {
      case 'patient':
        return const _PatientDashboard();
      case 'doctor':
        return const _DoctorDashboard();
      case 'hospital':
        return const _HospitalDashboard();
      default:
        return const Center(child: Text('Unknown user role'));
    }
  }
}

class _PatientDashboard extends StatelessWidget {
  const _PatientDashboard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Medora! 🏥',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your health companion is getting ready...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          
          // Coming Soon Features
          _buildFeatureCard(
            icon: Icons.emergency,
            title: 'Emergency SOS',
            description: 'Instant emergency alerts to contacts & hospitals',
            status: 'Coming Soon',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.medical_services,
            title: 'AI Health Assistant',
            description: '24/7 medical chatbot for symptom analysis',
            status: 'Coming Soon',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.assignment,
            title: 'Report Analyzer',
            description: 'AI-powered lab report analysis & insights',
            status: 'Coming Soon',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.nature,
            title: 'Ayurvedic Remedies',
            description: 'Natural treatments & wellness recommendations',
            status: 'Coming Soon',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required String status,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorDashboard extends StatelessWidget {
  const _DoctorDashboard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doctor Portal 🩺',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Doctor features coming soon...\n\n• Patient Management\n• Appointment Scheduling\n• Telemedicine\n• Prescription Management',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _HospitalDashboard extends StatelessWidget {
  const _HospitalDashboard();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Admin 🏥',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Hospital management features coming soon...\n\n• Bed Management\n• Staff Coordination\n• Emergency Response\n• Patient Records',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}