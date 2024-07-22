import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Pegawai'),
        // backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
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
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Silakan pilih opsi di bawah untuk melakukan absensi atau melihat status absensi Anda.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // Buttons Section
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildGridItem(
                    icon: Icons.check_circle,
                    label: 'Absen Masuk',
                    color: Colors.green,
                    onPressed: () {
                      // Action for Absen Masuk
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.logout,
                    label: 'Absen Keluar',
                    color: Colors.red,
                    onPressed: () {
                      // Action for Absen Keluar
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.calendar_today,
                    label: 'Lihat Riwayat',
                    color: Colors.blue,
                    onPressed: () {
                      // Action for Lihat Riwayat
                    },
                  ),
                  _buildGridItem(
                    icon: Icons.info,
                    label: 'Tentang Aplikasi',
                    color: Colors.orange,
                    onPressed: () {
                      // Action for Tentang Aplikasi
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 5.0,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 40.0,
              ),
              const SizedBox(height: 10.0),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
