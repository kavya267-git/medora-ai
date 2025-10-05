import 'package:flutter/material.dart';

class RoleSelector extends StatefulWidget {
  final void Function(String) onRoleSelected;

  const RoleSelector({
    super.key,
    required this.onRoleSelected,
  });

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  String _selectedRole = 'patient';

  final List<Map<String, dynamic>> _roles = [
    {
      'value': 'patient',
      'label': 'Patient',
      'icon': Icons.person_outline,
      'description': 'Track health & get emergency help',
    },
    {
      'value': 'doctor',
      'label': 'Doctor',
      'icon': Icons.medical_services_outlined,
      'description': 'Manage patients & consultations',
    },
    {
      'value': 'hospital',
      'label': 'Hospital',
      'icon': Icons.local_hospital_outlined,
      'description': 'Coordinate emergency responses',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onRoleSelected(_selectedRole);
      }
    });
  }

  void _handleRoleSelection(String role) {
    if (mounted) {
      setState(() {
        _selectedRole = role;
      });
      widget.onRoleSelected(role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Role',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _roles.map((role) {
            final isSelected = _selectedRole == role['value'];
            return _RoleCard(
              label: role['label'] as String,
              icon: role['icon'] as IconData,
              description: role['description'] as String,
              isSelected: isSelected,
              onTap: () => _handleRoleSelection(role['value'] as String),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withAlpha(51)
              : Colors.white.withAlpha(26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}