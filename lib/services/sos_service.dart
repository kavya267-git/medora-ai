import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send SOS alert to emergency contacts and hospitals
  Future<void> sendSOSAlert({
    required String userId,
    required String userName,
    required String userPhone,
    required List<Map<String, dynamic>> emergencyContacts,
  }) async {
    try {
      // Get current location
      final Position position = await _getCurrentLocation();
      final String locationString = 
          'Lat: ${position.latitude}, Lng: ${position.longitude}';
      final String googleMapsLink = 
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      // Create SOS alert document
      final sosAlertRef = _firestore.collection('sos_alerts').doc();
      final sosAlertData = {
        'id': sosAlertRef.id,
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': locationString,
        },
        'googleMapsLink': googleMapsLink,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active', // active, cancelled, resolved
        'sentToContacts': emergencyContacts.map((contact) => contact['phone']).toList(),
        'respondedBy': [],
      };

      await sosAlertRef.set(sosAlertData);

      // Send to emergency contacts (simulate SMS/email)
      await _notifyEmergencyContacts(
        emergencyContacts, 
        userName, 
        googleMapsLink
      );

      // Notify nearby hospitals
      await _notifyNearbyHospitals(
        position.latitude, 
        position.longitude, 
        sosAlertRef.id,
        userName,
        userPhone,
      );

    } catch (e) {
      throw Exception('Failed to send SOS alert: $e');
    }
  }

  // Get current location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Notify emergency contacts
  Future<void> _notifyEmergencyContacts(
    List<Map<String, dynamic>> contacts,
    String userName,
    String locationLink,
  ) async {
    for (final contact in contacts) {
      final String message = 
          '🚨 EMERGENCY ALERT 🚨\n'
          '$userName needs immediate help!\n'
          'Location: $locationLink\n'
          'Time: ${DateTime.now().toString()}\n'
          'Please check on them immediately!';

      // For phone contacts - launch SMS
      if (contact['phone'] != null) {
        await _launchSMS(contact['phone'], message);
      }

      // For email contacts - launch email
      if (contact['email'] != null) {
        await _launchEmail(contact['email'], 'EMERGENCY ALERT - $userName', message);
      }
    }
  }

  // Notify nearby hospitals
  Future<void> _notifyNearbyHospitals(
    double lat,
    double lng,
    String alertId,
    String userName,
    String userPhone,
  ) async {
    try {
      // Get hospitals within 10km radius
      final hospitals = await _getNearbyHospitals(lat, lng, radiusKm: 10);

      for (final hospital in hospitals) {
        await _firestore.collection('hospital_alerts').add({
          'hospitalId': hospital['id'],
          'hospitalName': hospital['name'],
          'alertId': alertId,
          'userName': userName,
          'userPhone': userPhone,
          'location': {'latitude': lat, 'longitude': lng},
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
          'distance': hospital['distance'],
        });
      }
    } catch (e) {
      // Continue even if hospital notification fails
      print('Hospital notification error: $e');
    }
  }

  // Get nearby hospitals (mock data - replace with actual API)
  Future<List<Map<String, dynamic>>> _getNearbyHospitals(
    double lat, 
    double lng, {
    double radiusKm = 10
  }) async {
    // Mock hospital data - replace with Google Places API or similar
    return [
      {
        'id': 'hosp_1',
        'name': 'City General Hospital',
        'latitude': lat + 0.01,
        'longitude': lng + 0.01,
        'phone': '+1234567890',
        'distance': 1.2,
      },
      {
        'id': 'hosp_2', 
        'name': 'Community Medical Center',
        'latitude': lat - 0.02,
        'longitude': lng + 0.015,
        'phone': '+1234567891',
        'distance': 2.5,
      },
    ];
  }

  // Launch SMS
  Future<void> _launchSMS(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );
    
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  // Launch Email
  Future<void> _launchEmail(String email, String subject, String body) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  // Get user's SOS history
  Stream<QuerySnapshot> getSOSHistory(String userId) {
    return _firestore
        .collection('sos_alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Cancel SOS alert
  Future<void> cancelSOSAlert(String alertId) async {
    await _firestore.collection('sos_alerts').doc(alertId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  // Resolve SOS alert
  Future<void> resolveSOSAlert(String alertId) async {
    await _firestore.collection('sos_alerts').doc(alertId).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}