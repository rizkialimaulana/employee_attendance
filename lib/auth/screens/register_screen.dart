import 'package:employee_attendance/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController jabatanController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _register() async {
    try {
      // Menggunakan email fiktif untuk registrasi karena Firebase memerlukan email
      String email = nikController.text + "@company.com";
      String password =
          "defaultPassword123"; // Gunakan password default atau buat sistem untuk menggenerate password

      // Membuat pengguna baru dengan email dan password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Menyimpan detail pengguna ke Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'nama': nameController.text,
          'nik': nikController.text,
          'jabatan': jabatanController.text,
        });

        // Pindah ke halaman berikutnya atau tampilkan pesan sukses
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Register",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nama",
                hintText: "Enter your full name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nikController,
              decoration: InputDecoration(
                labelText: "NIK",
                hintText: "Enter your employee number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: jabatanController,
              decoration: InputDecoration(
                labelText: "Jabatan",
                hintText: "Enter your position",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _register,
                child: Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
