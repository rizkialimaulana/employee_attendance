import 'package:employee_attendance/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user!.uid).get();
        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>?;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _changePassword(String newPassword) async {
    try {
      await user!.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password berhasil diubah')),
      );
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah password: $e')),
      );
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ganti Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password Baru',
              hintText: 'Masukkan password baru',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                String newPassword = passwordController.text.trim();
                if (newPassword.isNotEmpty) {
                  _changePassword(newPassword);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password baru tidak boleh kosong')),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pegawai'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Aksi untuk mengedit profil
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage('https://www.example.com/profile_image.jpg'),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Column(
                children: [
                  Text(
                    userData?['nama'] ?? 'Nama Pegawai',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    userData?['jabatan'] ?? 'Posisi Pegawai',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.account_circle),
                title: Text(userData?['nik'] ?? 'NIK'),
                onTap: () {
                  // Aksi untuk menampilkan detail NIK
                },
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Tentang Saya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Ini adalah deskripsi tentang pegawai. Anda dapat menambahkan informasi lebih lanjut tentang pegawai di sini.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _showChangePasswordDialog,
              child: Text('Ganti Password'),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
