import 'package:flutter/material.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointments'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Pending'),
              Tab(text: 'History'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showBookAppointment(context),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _UpcomingAppointments(),
            _PendingAppointments(),
            _AppointmentHistory(),
          ],
        ),
      ),
    );
  }

  void _showBookAppointment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _BookAppointmentSheet(),
    );
  }
}

class _UpcomingAppointments extends StatelessWidget {
  const _UpcomingAppointments();

  @override
  Widget build(BuildContext context) {
    final appointments = [
      _Appointment(
        doctorName: 'Dr. Sarah Johnson',
        specialty: 'Cardiologist',
        date: '20 Dec 2024',
        time: '10:00 AM',
        location: 'City Hospital',
        status: 'confirmed',
      ),
      _Appointment(
        doctorName: 'Dr. Mike Chen',
        specialty: 'General Physician',
        date: '22 Dec 2024',
        time: '2:30 PM',
        location: 'Health Plus Clinic',
        status: 'confirmed',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentCard(appointment: appointment);
      },
    );
  }
}

class _PendingAppointments extends StatelessWidget {
  const _PendingAppointments();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'No Pending Appointments',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _AppointmentHistory extends StatelessWidget {
  const _AppointmentHistory();

  @override
  Widget build(BuildContext context) {
    final history = [
      _Appointment(
        doctorName: 'Dr. Emily Davis',
        specialty: 'Dermatologist',
        date: '10 Dec 2024',
        time: '11:00 AM',
        location: 'Skin Care Center',
        status: 'completed',
      ),
      _Appointment(
        doctorName: 'Dr. James Wilson',
        specialty: 'Orthopedic',
        date: '05 Dec 2024',
        time: '3:00 PM',
        location: 'Bone & Joint Clinic',
        status: 'completed',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final appointment = history[index];
        return _AppointmentCard(appointment: appointment);
      },
    );
  }
}

class _Appointment {
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String location;
  final String status;

  _Appointment({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
  });
}

class _AppointmentCard extends StatelessWidget {
  final _Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment.specialty,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    appointment.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoItem(
                  icon: Icons.calendar_today,
                  text: appointment.date,
                ),
                const SizedBox(width: 16),
                _InfoItem(
                  icon: Icons.access_time,
                  text: appointment.time,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoItem(
              icon: Icons.location_on,
              text: appointment.location,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showAppointmentDetails(context, appointment),
                    child: const Text('VIEW DETAILS'),
                  ),
                ),
                const SizedBox(width: 8),
                if (appointment.status == 'confirmed')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rescheduleAppointment(context, appointment),
                      child: const Text('RESCHEDULE'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAppointmentDetails(BuildContext context, _Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Appointment with ${appointment.doctorName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specialty: ${appointment.specialty}'),
            Text('Date: ${appointment.date}'),
            Text('Time: ${appointment.time}'),
            Text('Location: ${appointment.location}'),
            Text('Status: ${appointment.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          if (appointment.status == 'confirmed')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelAppointment(context, appointment);
              },
              child: const Text('CANCEL', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(BuildContext context, _Appointment appointment) {
    // TODO: Implement reschedule functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reschedule functionality coming soon!')),
    );
  }

  void _cancelAppointment(BuildContext context, _Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appointment cancelled!')),
              );
            },
            child: const Text('YES', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _BookAppointmentSheet extends StatefulWidget {
  const _BookAppointmentSheet();

  @override
  State<_BookAppointmentSheet> createState() => _BookAppointmentSheetState();
}

class _BookAppointmentSheetState extends State<_BookAppointmentSheet> {
  String _selectedSpecialty = 'General Physician';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _bookAppointment() {
    // TODO: Implement appointment booking
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment booked successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book New Appointment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Specialty Selection
          DropdownButtonFormField<String>(
            value: _selectedSpecialty,
            decoration: const InputDecoration(
              labelText: 'Specialty',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'General Physician', child: Text('General Physician')),
              DropdownMenuItem(value: 'Cardiologist', child: Text('Cardiologist')),
              DropdownMenuItem(value: 'Dermatologist', child: Text('Dermatologist')),
              DropdownMenuItem(value: 'Orthopedic', child: Text('Orthopedic')),
              DropdownMenuItem(value: 'Pediatrician', child: Text('Pediatrician')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSpecialty = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Date Selection
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            controller: TextEditingController(
              text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'
            ),
            onTap: () => _selectDate(context),
          ),
          
          const SizedBox(height: 16),
          
          // Time Selection
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Time',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            readOnly: true,
            controller: TextEditingController(
              text: _selectedTime.format(context)
            ),
            onTap: () => _selectTime(context),
          ),
          
          const SizedBox(height: 24),
          
          // Book Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _bookAppointment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('BOOK APPOINTMENT'),
            ),
          ),
        ],
      ),
    );
  }
}