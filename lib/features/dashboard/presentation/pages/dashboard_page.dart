import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../emergency/emergency_page.dart';
import '../../../chatbot/chatbot_page.dart';
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
    return SingleChildScrollView(
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

          // Emergency SOS Card
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.emergency, size: 40, color: Colors.red),
              title: const Text(
                'Emergency SOS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Instant emergency alerts to contacts & hospitals'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const EmergencyPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // AI Health Assistant Card
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.medical_services, size: 40, color: Colors.green),
              title: const Text(
                'AI Health Assistant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('24/7 medical chatbot with Ayurvedic remedies'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => const ChatbotPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Coming Soon Features
          _buildFeatureCard(
            icon: Icons.assignment,
            title: 'Medical Records',
            description: 'Secure storage and management of health reports',
            status: 'Coming Soon',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.calendar_today,
            title: 'Appointments',
            description: 'Book doctor appointments and manage schedules',
            status: 'Coming Soon',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.monitor_heart,
            title: 'Health Tracking',
            description: 'Monitor BP, sugar, and vital parameters',
            status: 'Coming Soon',
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.nature,
            title: 'Ayurvedic Remedies',
            description: 'Traditional treatments and wellness plans',
            status: 'Integrated in AI Assistant',
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Color(0xFFD97706),
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