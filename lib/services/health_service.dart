import 'package:cloud_firestore/cloud_firestore.dart';

class HealthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add BP record
  Future<void> addBPRecord({
    required String userId,
    required int systolic,
    required int diastolic,
    required int heartRate,
    required String notes,
    required DateTime timestamp,
  }) async {
    try {
      await _firestore.collection('bp_records').add({
        'userId': userId,
        'systolic': systolic,
        'diastolic': diastolic,
        'heartRate': heartRate,
        'notes': notes,
        'timestamp': timestamp,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save BP record: $e');
    }
  }

  // Add Sugar record
  Future<void> addSugarRecord({
    required String userId,
    required double sugarLevel,
    required String measurementType, // fasting, postMeal, random
    required String notes,
    required DateTime timestamp,
  }) async {
    try {
      await _firestore.collection('sugar_records').add({
        'userId': userId,
        'sugarLevel': sugarLevel,
        'measurementType': measurementType,
        'notes': notes,
        'timestamp': timestamp,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save sugar record: $e');
    }
  }

  // Get BP records for user
  Stream<QuerySnapshot> getBPRecords(String userId) {
    return _firestore
        .collection('bp_records')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get Sugar records for user
  Stream<QuerySnapshot> getSugarRecords(String userId) {
    return _firestore
        .collection('sugar_records')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get BP records for date range
  Stream<QuerySnapshot> getBPRecordsByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) {
    return _firestore
        .collection('bp_records')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get Sugar records for date range
  Stream<QuerySnapshot> getSugarRecordsByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) {
    return _firestore
        .collection('sugar_records')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Delete BP record
  Future<void> deleteBPRecord(String recordId) async {
    try {
      await _firestore.collection('bp_records').doc(recordId).delete();
    } catch (e) {
      throw Exception('Failed to delete BP record: $e');
    }
  }

  // Delete Sugar record
  Future<void> deleteSugarRecord(String recordId) async {
    try {
      await _firestore.collection('sugar_records').doc(recordId).delete();
    } catch (e) {
      throw Exception('Failed to delete sugar record: $e');
    }
  }

  // Analyze BP trends
  Future<Map<String, dynamic>> analyzeBPTrends(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final snapshot = await _firestore
        .collection('bp_records')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: weekAgo)
        .orderBy('timestamp')
        .get();

    if (snapshot.docs.isEmpty) {
      return {
        'averageSystolic': 0,
        'averageDiastolic': 0,
        'trend': 'no_data',
        'message': 'No BP records found for the last 7 days',
      };
    }

    double totalSystolic = 0;
    double totalDiastolic = 0;
    int count = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalSystolic += (data['systolic'] as int).toDouble();
      totalDiastolic += (data['diastolic'] as int).toDouble();
      count++;
    }

    final avgSystolic = totalSystolic / count;
    final avgDiastolic = totalDiastolic / count;

    String trend;
    String message;

    if (avgSystolic < 120 && avgDiastolic < 80) {
      trend = 'normal';
      message = 'Your blood pressure is within normal range.';
    } else if (avgSystolic >= 120 && avgSystolic <= 129 && avgDiastolic < 80) {
      trend = 'elevated';
      message = 'Your blood pressure is elevated. Consider lifestyle changes.';
    } else if (avgSystolic >= 130 || avgDiastolic >= 80) {
      trend = 'high';
      message = 'Your blood pressure is high. Please consult a doctor.';
    } else {
      trend = 'unknown';
      message = 'Unable to determine trend.';
    }

    return {
      'averageSystolic': avgSystolic.round(),
      'averageDiastolic': avgDiastolic.round(),
      'trend': trend,
      'message': message,
      'recordCount': count,
    };
  }

  // Analyze Sugar trends
  Future<Map<String, dynamic>> analyzeSugarTrends(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final snapshot = await _firestore
        .collection('sugar_records')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: weekAgo)
        .orderBy('timestamp')
        .get();

    if (snapshot.docs.isEmpty) {
      return {
        'averageSugar': 0,
        'trend': 'no_data',
        'message': 'No sugar records found for the last 7 days',
      };
    }

    double totalSugar = 0;
    int count = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalSugar += (data['sugarLevel'] as double);
      count++;
    }

    final avgSugar = totalSugar / count;

    String trend;
    String message;

    if (avgSugar < 100) {
      trend = 'normal';
      message = 'Your blood sugar levels are normal.';
    } else if (avgSugar >= 100 && avgSugar <= 125) {
      trend = 'prediabetes';
      message = 'Your blood sugar levels indicate prediabetes.';
    } else {
      trend = 'diabetes';
      message = 'Your blood sugar levels are high. Please consult a doctor.';
    }

    return {
      'averageSugar': double.parse(avgSugar.toStringAsFixed(1)),
      'trend': trend,
      'message': message,
      'recordCount': count,
    };
  }
}