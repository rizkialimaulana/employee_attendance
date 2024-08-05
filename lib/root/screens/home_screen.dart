import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_screen.dart';
import 'report_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart'; // Import package untuk format tanggal

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>?;
          });
          fetchAttendanceHistory(userData?['nik']);
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> fetchAttendanceHistory(String? nik) async {
    if (nik != null) {
      try {
        QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
            .collection('attendances')
            .where('nik', isEqualTo: nik)
            .get();
        setState(() {
          attendanceHistory = attendanceSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      } catch (e) {
        print('Error fetching attendance history: $e');
      }
    }
  }

  Future<void> _refreshData() async {
    await fetchUserData();
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.menu),
            CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://www.gravatar.com/avatar/2c7d99fe281ecd3bcd65ab915bac6dd5?s=250'), // Ganti dengan URL gambar profil Anda
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${userData?['nama'] ?? 'Pegawai'}!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Silakan pilih opsi di bawah untuk melaporkan pekerjaan Anda atau melihat status laporan.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search',
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Featured categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryItem(
                      icon: Icons.assignment,
                      label: 'Lapor Pekerjaan',
                      page: AttendanceScreen()),
                  _buildCategoryItem(
                      icon: Icons.history,
                      label: 'Lihat Laporan',
                      page: ReportScreen()),
                  _buildCategoryItem(
                      icon: Icons.bar_chart,
                      label: 'Statistik',
                      page: ReportScreen()),
                  _buildCategoryItem(
                      icon: Icons.info,
                      label: 'Profile',
                      page: ProfileScreen()),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                'Riwayat Pelaporan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Expanded(
                child: attendanceHistory.isNotEmpty
                    ? ListView.builder(
                        itemCount: attendanceHistory.length,
                        itemBuilder: (context, index) {
                          var report = attendanceHistory[index];
                          return _buildReportHistory(
                            icon: Icons.assignment_turned_in_outlined,
                            title: report['judul'] ?? 'Judul tidak diketahui',
                            date: report['timestamp'] != null
                                ? formatDate(report['timestamp'] as Timestamp)
                                : 'Tanggal tidak diketahui',
                            description: report['deskripsi'] ??
                                'Deskripsi tidak diketahui',
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Tidak ada riwayat pelaporan pekerjaan anda, silahkan lapor pekerjaan anda',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () =>
                                _navigateToPage(AttendanceScreen()),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Lapor Pekerjaan',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      {required IconData icon, required String label, required Widget page}) {
    return GestureDetector(
      onTap: () => _navigateToPage(page),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          SizedBox(height: 8.0),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildReportHistory({
    required IconData icon,
    required String title,
    required String date,
    required String description,
  }) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Icon(icon, size: 40, color: Colors.blue),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4.0),
                  Text(date,
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  SizedBox(height: 8.0),
                  Text(description,
                      style: TextStyle(fontSize: 14, color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
