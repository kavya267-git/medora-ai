import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class HospitalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock hospital database - replace with actual API
  final List<Map<String, dynamic>> _hospitals = [
    {
      'id': 'hosp_1',
      'name': 'City General Hospital',
      'address': '123 Main Street, City Center',
      'phone': '+1-234-567-8900',
      'emergencyPhone': '+1-234-567-8911',
      'latitude': 40.7128,
      'longitude': -74.0060,
      'specialties': ['Emergency', 'Cardiology', 'General Medicine'],
      'availableBeds': 15,
      'isEmergencyAvailable': true,
      'distance': 0.0,
    },
    {
      'id': 'hosp_2',
      'name': 'Community Medical Center',
      'address': '456 Oak Avenue, Suburbia',
      'phone': '+1-234-567-8901',
      'emergencyPhone': '+1-234-567-8912',
      'latitude': 40.7282,
      'longitude': -73.9942,
      'specialties': ['Pediatrics', 'Orthopedics', 'Emergency'],
      'availableBeds': 8,
      'isEmergencyAvailable': true,
      'distance': 0.0,
    },
    {
      'id': 'hosp_3',
      'name': 'Metropolitan Health Institute',
      'address': '789 Park Boulevard, Downtown',
      'phone': '+1-234-567-8902',
      'emergencyPhone': '+1-234-567-8913',
      'latitude': 40.7580,
      'longitude': -73.9855,
      'specialties': ['Surgery', 'Neurology', 'Oncology'],
      'availableBeds': 22,
      'isEmergencyAvailable': true,
      'distance': 0.0,
    },
  ];

  // Get nearby hospitals with distance calculation
  Future<List<Map<String, dynamic>>> getNearbyHospitals({
    required double userLat,
    required double userLng,
    double radiusKm = 10.0,
  }) async {
    final List<Map<String, dynamic>> nearbyHospitals = [];

    for (final hospital in _hospitals) {
      final double distance = _calculateDistance(
        userLat,
        userLng,
        hospital['latitude'],
        hospital['longitude'],
      );

      if (distance <= radiusKm) {
        nearbyHospitals.add({
          ...hospital,
          'distance': double.parse(distance.toStringAsFixed(1)),
        });
      }
    }

    // Sort by distance
    nearbyHospitals.sort((a, b) => a['distance'].compareTo(b['distance']));

    return nearbyHospitals;
  }

  // Calculate distance between two points in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // Get hospital by ID
  Future<Map<String, dynamic>?> getHospitalById(String hospitalId) async {
    try {
      return _hospitals.firstWhere(
        (hospital) => hospital['id'] == hospitalId,
      );
    } catch (e) {
      return null;
    }
  }

  // Search hospitals by name or specialty
  Future<List<Map<String, dynamic>>> searchHospitals(String query) async {
    final String lowerQuery = query.toLowerCase();
    
    return _hospitals.where((hospital) {
      final String name = hospital['name'].toString().toLowerCase();
      final String address = hospital['address'].toString().toLowerCase();
      final List<String> specialties = 
          (hospital['specialties'] as List).cast<String>();
      
      final bool nameMatch = name.contains(lowerQuery);
      final bool addressMatch = address.contains(lowerQuery);
      final bool specialtyMatch = specialties.any(
        (specialty) => specialty.toLowerCase().contains(lowerQuery)
      );

      return nameMatch || addressMatch || specialtyMatch;
    }).toList();
  }

  // Get hospitals with emergency services
  Future<List<Map<String, dynamic>>> getEmergencyHospitals({
    double? userLat,
    double? userLng,
  }) async {
    List<Map<String, dynamic>> emergencyHospitals = _hospitals
        .where((hospital) => hospital['isEmergencyAvailable'] == true)
        .toList();

    // Sort by distance if user location is provided
    if (userLat != null && userLng != null) {
      for (final hospital in emergencyHospitals) {
        hospital['distance'] = _calculateDistance(
          userLat,
          userLng,
          hospital['latitude'],
          hospital['longitude'],
        );
      }
      
      emergencyHospitals.sort((a, b) => a['distance'].compareTo(b['distance']));
    }

    return emergencyHospitals;
  }

  // Send SOS alert to specific hospital
  Future<void> sendSOSToHospital({
    required String hospitalId,
    required String alertId,
    required String userName,
    required String userPhone,
    required double userLat,
    required double userLng,
  }) async {
    try {
      await _firestore.collection('hospital_alerts').add({
        'hospitalId': hospitalId,
        'alertId': alertId,
        'userName': userName,
        'userPhone': userPhone,
        'userLocation': {
          'latitude': userLat,
          'longitude': userLng,
        },
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'googleMapsLink': 
            'https://maps.google.com/?q=$userLat,$userLng',
      });
    } catch (e) {
      throw Exception('Failed to send alert to hospital: $e');
    }
  }

  // Update hospital alert status
  Future<void> updateHospitalAlertStatus({
    required String alertId,
    required String status, // pending, accepted, en_route, arrived
    String? responseNotes,
  }) async {
    try {
      await _firestore.collection('hospital_alerts').doc(alertId).update({
        'status': status,
        'responseNotes': responseNotes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update alert status: $e');
    }
  }

  // Get hospital alerts
  Stream<QuerySnapshot> getHospitalAlerts(String hospitalId) {
    return _firestore
        .collection('hospital_alerts')
        .where('hospitalId', isEqualTo: hospitalId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get directions to hospital
  String getDirectionsUrl(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return 'https://www.google.com/maps/dir/?api=1'
           '&origin=$startLat,$startLng'
           '&destination=$endLat,$endLng'
           '&travelmode=driving';
  }

  // Call hospital emergency number
  Future<void> callHospitalEmergency(String phoneNumber) async {
    // This would typically use url_launcher to call the number
    // For now, we return the phone number
    print('Calling hospital emergency: $phoneNumber');
  }

  // Get hospital stats
  Future<Map<String, dynamic>> getHospitalStats(String hospitalId) async {
    // Mock stats - replace with actual data
    return {
      'totalAlerts': 15,
      'activeAlerts': 2,
      'averageResponseTime': '12 minutes',
      'completionRate': '92%',
    };
  }
}