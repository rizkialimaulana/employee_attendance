import 'package:flutter/material.dart';
import 'package:employee_attendance/root/screens/home_screen.dart';
import 'package:employee_attendance/root/screens/profile_screen.dart';
import 'package:employee_attendance/root/screens/attendance_screen.dart';
import 'package:employee_attendance/root/screens/report_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    AttendanceScreen(),
    ReportScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined, size: 30),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_present_outlined, size: 30),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined, size: 30),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}
