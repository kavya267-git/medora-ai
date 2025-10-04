import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medora_new/services/auth_service.dart';
import 'package:medora_new/services/health_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  // Card sizes - users can adjust these
  double _bpCardHeight = 200.0;
  double _sugarCardHeight = 180.0;
  double _sosCardHeight = 160.0;
  double _chatbotCardHeight = 220.0;
  
  bool _isEditingLayout = false;
  
  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late HealthService _healthService;

  @override
  void initState() {
    super.initState();
    
    _healthService = HealthService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLayoutEditing() {
    setState(() {
      _isEditingLayout = !_isEditingLayout;
    });
  }

  void _resetLayout() {
    setState(() {
      _bpCardHeight = 200.0;
      _sugarCardHeight = 180.0;
      _sosCardHeight = 160.0;
      _chatbotCardHeight = 220.0;
    });
  }

  // Firebase: Add BP Reading
  Future<void> _addBPReading() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    try {
      await _healthService.addBPRecord(
        userId: user.uid,
        systolic: 120,
        diastolic: 80,
        heartRate: 72,
        notes: 'Manual reading from dashboard',
        timestamp: DateTime.now(),
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BP reading added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding BP reading: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Firebase: Add Sugar Reading
  Future<void> _addSugarReading() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    try {
      await _healthService.addSugarRecord(
        userId: user.uid,
        sugarLevel: 98.0,
        measurementType: 'fasting',
        notes: 'Morning fasting reading',
        timestamp: DateTime.now(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sugar reading added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding sugar reading: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          );
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar with User Info
            _buildAppBar(user),
            
            // Welcome Section with Real User Data
            _buildWelcomeSection(user),
            
            // Real-time Health Stats from Firebase
            _buildRealTimeStats(user),
            
            // Health Features Grid (Resizable Cards)
            _buildHealthFeaturesGrid(),
            
            // Recent Activity from Firebase
            _buildRecentActivityFromFirebase(user),
            
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
      
      // Floating Action Button for Layout Editing
      floatingActionButton: _buildLayoutFab(),
    );
  }

  SliverAppBar _buildAppBar(User? user) {
    return SliverAppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      floating: true,
      snap: true,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Medora',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        // Firebase: User Profile Picture
        if (user?.photoURL != null)
          CircleAvatar(
            backgroundImage: NetworkImage(user!.photoURL!),
            radius: 16,
          )
        else
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Text(
              user?.displayName?.substring(0, 1) ?? 'U',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.notifications_active_rounded),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            if (value == 'logout') {
              Provider.of<AuthService>(context, listen: false).signOut();
            } else if (value == 'edit_layout') {
              _toggleLayoutEditing();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit_layout',
              child: Row(
                children: [
                  Icon(Icons.dashboard_rounded, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  const Text('Edit Layout'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildWelcomeSection(User? user) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.lightBlue.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade300.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Firebase: Real User Name
                  Text(
                    'Welcome back, ${user?.displayName ?? user?.email?.split('@').first ?? 'Hero'}! 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Firebase: Real Health Score
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('health_scores')
                        .where('userId', isEqualTo: user?.uid)
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      int healthScore = 92; // Default score
                      
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                        healthScore = data['score'] ?? 92;
                      }
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Your health score: $healthScore/100 ${healthScore > 90 ? '🔥' : healthScore > 70 ? '👍' : '😊'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.health_and_safety_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRealTimeStats(User? user) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Firebase: Real Heart Rate
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('bp_records')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                String heartRate = '72';
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  heartRate = data['heartRate']?.toString() ?? '72';
                }
                
                return _buildStatCard(
                  'Heart Rate',
                  heartRate,
                  'BPM',
                  Icons.favorite_rounded,
                  Colors.red.shade400,
                );
              },
            ),
            const SizedBox(width: 12),
            
            // Firebase: Real BP Data
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('bp_records')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                String bpValue = '120/80';
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final systolic = data['systolic'] ?? 120;
                  final diastolic = data['diastolic'] ?? 80;
                  bpValue = '$systolic/$diastolic';
                }
                
                return _buildStatCard(
                  'BP Today',
                  bpValue,
                  'mmHg',
                  Icons.monitor_heart_rounded,
                  Colors.green.shade400,
                );
              },
            ),
            const SizedBox(width: 12),
            
            // Firebase: Real Sugar Data
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('sugar_records')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                String sugarValue = '98';
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  sugarValue = data['sugarLevel']?.toString() ?? '98';
                }
                
                return _buildStatCard(
                  'Sugar',
                  sugarValue,
                  'mg/dL',
                  Icons.bloodtype_rounded,
                  Colors.orange.shade400,
                );
              },
            ),
            const SizedBox(width: 12),
            
            _buildStatCard(
              'Sleep',
              '7.5',
              'hours',
              Icons.nightlight_rounded,
              Colors.purple.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHealthFeaturesGrid() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Health Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_isEditingLayout)
                  TextButton.icon(
                    onPressed: _resetLayout,
                    icon: const Icon(Icons.restart_alt_rounded, size: 16),
                    label: const Text('Reset Layout'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // BP Tracking Card with Firebase Integration
            _buildResizableCard(
              height: _bpCardHeight,
              onHeightChanged: (height) => setState(() => _bpCardHeight = height),
              child: _buildBPCard(),
              isEditing: _isEditingLayout,
            ),
            
            const SizedBox(height: 16),
            
            // Sugar Tracking Card with Firebase Integration
            _buildResizableCard(
              height: _sugarCardHeight,
              onHeightChanged: (height) => setState(() => _sugarCardHeight = height),
              child: _buildSugarCard(),
              isEditing: _isEditingLayout,
            ),
            
            const SizedBox(height: 16),
            
            // SOS Emergency Card
            _buildResizableCard(
              height: _sosCardHeight,
              onHeightChanged: (height) => setState(() => _sosCardHeight = height),
              child: _buildSOSCard(),
              isEditing: _isEditingLayout,
            ),
            
            const SizedBox(height: 16),
            
            // Symptom Chatbot Card
            _buildResizableCard(
              height: _chatbotCardHeight,
              onHeightChanged: (height) => setState(() => _chatbotCardHeight = height),
              child: _buildChatbotCard(),
              isEditing: _isEditingLayout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResizableCard({
    required double height,
    required Function(double) onHeightChanged,
    required Widget child,
    required bool isEditing,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      child: Stack(
        children: [
          // Main Card Content
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: child,
            ),
          ),
          
          // Resize Handle (Only visible in edit mode)
          if (isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  final newHeight = height + details.delta.dy;
                  if (newHeight >= 120 && newHeight <= 400) {
                    onHeightChanged(newHeight);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: const Icon(
                    Icons.open_with_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBPCard() {
    final user = Provider.of<AuthService>(context).currentUser;
    
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bp_records')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        int systolic = 120;
        int diastolic = 80;
        int heartRate = 72;
        String status = 'Normal';
        Color statusColor = Colors.green;
        String lastReading = '2h ago';
        
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          systolic = data['systolic'] ?? 120;
          diastolic = data['diastolic'] ?? 80;
          heartRate = data['heartRate'] ?? 72;
          
          // Determine BP status
          if (systolic >= 140 || diastolic >= 90) {
            status = 'High';
            statusColor = Colors.red;
          } else if (systolic >= 130 || diastolic >= 85) {
            status = 'Elevated';
            statusColor = Colors.orange;
          }
          
          // Calculate time ago
          final timestamp = data['timestamp'] as Timestamp?;
          if (timestamp != null) {
            final now = DateTime.now();
            final difference = now.difference(timestamp.toDate());
            if (difference.inMinutes < 60) {
              lastReading = '${difference.inMinutes}m ago';
            } else if (difference.inHours < 24) {
              lastReading = '${difference.inHours}h ago';
            } else {
              lastReading = '${difference.inDays}d ago';
            }
          }
        }
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.monitor_heart_rounded,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Blood Pressure',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$systolic/$diastolic',
                            style: TextStyle(
                              fontSize: _bpCardHeight > 180 ? 32 : 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text(
                            'mmHg',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last reading: $lastReading',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Heart rate: $heartRate BPM',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_bpCardHeight > 160)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.show_chart_rounded,
                              color: Colors.blue.shade400,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_bpCardHeight > 200)
                const SizedBox(height: 16),
              if (_bpCardHeight > 200)
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _addBPReading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Reading'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSugarCard() {
    final user = Provider.of<AuthService>(context).currentUser;
    
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('sugar_records')
          .where('userId', isEqualTo: user?.uid)
          .where('measurementType', isEqualTo: 'fasting')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        double fastingSugar = 98.0;
        double postMealSugar = 132.0;
        String status = 'Normal';
        Color statusColor = Colors.green;
        
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          fastingSugar = (data['sugarLevel'] as num?)?.toDouble() ?? 98.0;
          
          // Determine sugar status
          if (fastingSugar >= 126) {
            status = 'High';
            statusColor = Colors.red;
          } else if (fastingSugar >= 100) {
            status = 'Elevated';
            statusColor = Colors.orange;
          }
        }
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bloodtype_rounded,
                      color: Colors.orange.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Blood Sugar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '$fastingSugar mg/dL',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Fasting',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fastingSugar.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: _sugarCardHeight > 160 ? 28 : 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          Text(
                            'mg/dL',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_sugarCardHeight > 140)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'After Meal',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              postMealSugar.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: _sugarCardHeight > 160 ? 22 : 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange.shade600,
                              ),
                            ),
                            Text(
                              'mg/dL',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (_sugarCardHeight > 200)
                const SizedBox(height: 16),
              if (_sugarCardHeight > 200)
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _addSugarReading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Reading'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ... (Keep the rest of the SOS, Chatbot, and other methods the same as before)
  // The SOS and Chatbot cards don't need Firebase integration yet

  Widget _buildSOSCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emergency_rounded,
                  color: Colors.red.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Emergency SOS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade400,
                          Colors.red.shade600,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade300.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Press in case of emergency',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_sosCardHeight > 140)
                    const SizedBox(height: 12),
                  if (_sosCardHeight > 140)
                    Text(
                      'Will alert your emergency contacts',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatbotCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medical_information_rounded,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Symptom Checker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: [
                Text(
                  'AI-Powered Health Assistant',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.psychology_rounded,
                        color: Colors.green.shade600,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Describe your symptoms',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get Ayurvedic remedies and advice',
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_chatbotCardHeight > 200)
                  const SizedBox(height: 16),
                if (_chatbotCardHeight > 200)
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3,
                      children: [
                        _buildSymptomChip('Fever', Icons.thermostat_rounded),
                        _buildSymptomChip('Headache', Icons.sick_rounded),
                        _buildSymptomChip('Cough', Icons.air_rounded),
                        _buildSymptomChip('Digestion', Icons.health_and_safety_rounded),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text('Start Chat'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomChip(String symptom, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 4),
          Text(
            symptom,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

 SliverToBoxAdapter _buildRecentActivityFromFirebase(User? user) {
  return SliverToBoxAdapter(
    child: StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('recent_activities')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final activities = snapshot.data!.docs;

        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              if (activities.isEmpty)
                const Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...activities.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildActivityItem(
                    data['title'] ?? 'Activity',
                    data['description'] ?? '',
                    _getActivityIcon(data['type']),
                    _getActivityColor(data['type']),
                    _getTimeAgo(data['timestamp']),
                  );
                }).toList(),
            ],
          ),
        );
      },
    ),
  );
}

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'bp':
        return Icons.monitor_heart_rounded;
      case 'sugar':
        return Icons.bloodtype_rounded;
      case 'medication':
        return Icons.medication_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'bp':
        return Colors.blue;
      case 'sugar':
        return Colors.orange;
      case 'medication':
        return Colors.green;
      case 'water':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Recently';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutFab() {
    return FloatingActionButton(
      onPressed: _toggleLayoutEditing,
      backgroundColor: _isEditingLayout ? Colors.orange.shade600 : Colors.blue.shade600,
      foregroundColor: Colors.white,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isEditingLayout
            ? const Icon(Icons.check_rounded, key: ValueKey('check'))
            : const Icon(Icons.dashboard_rounded, key: ValueKey('dashboard')),
      ),
    );
  }
}