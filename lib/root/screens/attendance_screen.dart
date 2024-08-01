import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isCheckedIn = false;
  String statusMessage = "Lokasi belum terdeteksi.";
  String currentLocation = "Lokasi belum terdeteksi.";
  TextEditingController descriptionController = TextEditingController();
  File? _image;
  Position? _currentPosition;

  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')),
      );
      return;
    }

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (_currentPosition != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentLocation =
              "${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
          statusMessage = "Lokasi berhasil dideteksi.";
        });
      }
    }
  }

  Future<void> submitAttendance() async {
    if (descriptionController.text.isEmpty ||
        _image == null ||
        _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Semua field harus diisi dan lokasi harus dideteksi')),
      );
      return;
    }

    String imageUrl = await uploadImage();

    await FirebaseFirestore.instance.collection('attendances').add({
      'description': descriptionController.text,
      'imageUrl': imageUrl,
      'status': isCheckedIn ? 'Checked In' : 'Checked Out',
      'location':
          GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
      'locationDetails': currentLocation,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pekerjaan anda berhasil di report')),
    );

    // Reset fields after submission
    setState(() {
      descriptionController.clear();
      _image = null;
      _currentPosition = null;
      currentLocation = "Lokasi belum terdeteksi.";
      statusMessage = "Lokasi belum terdeteksi.";
      isCheckedIn = false;
    });
  }

  Future<String> uploadImage() async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('attendance_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    await storageRef.putFile(_image!);

    return await storageRef.getDownloadURL();
  }

  void detectLocationIn() {
    setState(() {
      isCheckedIn = true;
    });
    _getCurrentLocation();
  }

  void detectLocationOut() {
    setState(() {
      isCheckedIn = false;
    });
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Pegawai'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Location Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi saat ini',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    currentLocation,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // Description Input Section
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Pekerjaan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20.0),
            // Image Picker Section
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Upload Foto Bukti'),
            ),
            if (_image != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Image.file(
                  _image!,
                  height: 150,
                ),
              ),
            const SizedBox(height: 20.0),
            // Check-in / Check-out Button Section
            ElevatedButton(
              onPressed: isCheckedIn ? null : detectLocationIn,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Deteksi Lokasi Masuk',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: !isCheckedIn ? null : detectLocationOut,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Deteksi Lokasi Keluar',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20.0),
            // Submit Button Section
            ElevatedButton(
              onPressed: submitAttendance,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Submit Absensi',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
