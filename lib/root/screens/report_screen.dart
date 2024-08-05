import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<int> attendanceData = List.filled(12, 0);
  bool _isLoading = true;
  String? _nik;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _nik = userDoc['nik'];
          });
          print('NIK: $_nik'); // Debug print
          fetchAttendanceData(_nik);
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> fetchAttendanceData(String? nik) async {
    if (nik == null) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('attendances')
          .where('nik', isEqualTo: nik)
          .orderBy('timestamp', descending: true)
          .get();

      Map<int, int> monthlyData = {};
      snapshot.docs.forEach((doc) {
        Timestamp timestamp = doc['timestamp'];
        DateTime date = timestamp.toDate();
        int month = date.month;

        if (monthlyData.containsKey(month)) {
          monthlyData[month] = monthlyData[month]! + 1;
        } else {
          monthlyData[month] = 1;
        }
      });

      List<int> data =
          List.generate(12, (index) => monthlyData[index + 1] ?? 0);
      print('Attendance Data: $data'); // Debug print

      setState(() {
        attendanceData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching attendance data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pekerjaan'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Grafik Laporan Pekerjaan Pegawai',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                String month;
                                switch (group.x.toInt()) {
                                  case 0:
                                    month = 'Jan';
                                    break;
                                  case 1:
                                    month = 'Feb';
                                    break;
                                  case 2:
                                    month = 'Mar';
                                    break;
                                  case 3:
                                    month = 'Apr';
                                    break;
                                  case 4:
                                    month = 'Mei';
                                    break;
                                  case 5:
                                    month = 'Jun';
                                    break;
                                  case 6:
                                    month = 'Jul';
                                    break;
                                  case 7:
                                    month = 'Agu';
                                    break;
                                  case 8:
                                    month = 'Sep';
                                    break;
                                  case 9:
                                    month = 'Okt';
                                    break;
                                  case 10:
                                    month = 'Nov';
                                    break;
                                  case 11:
                                    month = 'Des';
                                    break;
                                  default:
                                    throw Error();
                                }
                                return BarTooltipItem(
                                  '$month\n',
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: (rod.toY).toString(),
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const style = TextStyle(
                                    color: Color(0xff68737d),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 0:
                                      text = const Text('Jan', style: style);
                                      break;
                                    case 1:
                                      text = const Text('Feb', style: style);
                                      break;
                                    case 2:
                                      text = const Text('Mar', style: style);
                                      break;
                                    case 3:
                                      text = const Text('Apr', style: style);
                                      break;
                                    case 4:
                                      text = const Text('Mei', style: style);
                                      break;
                                    case 5:
                                      text = const Text('Jun', style: style);
                                      break;
                                    case 6:
                                      text = const Text('Jul', style: style);
                                      break;
                                    case 7:
                                      text = const Text('Agu', style: style);
                                      break;
                                    case 8:
                                      text = const Text('Sep', style: style);
                                      break;
                                    case 9:
                                      text = const Text('Okt', style: style);
                                      break;
                                    case 10:
                                      text = const Text('Nov', style: style);
                                      break;
                                    case 11:
                                      text = const Text('Des', style: style);
                                      break;
                                    default:
                                      text = const Text('', style: style);
                                      break;
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: text,
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const style = TextStyle(
                                    color: Color(0xff68737d),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );
                                  return Text(value.toInt().toString(),
                                      style: style);
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          gridData: FlGridData(show: false),
                          barGroups: attendanceData
                              .asMap()
                              .entries
                              .map((e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: [
                                      BarChartRodData(
                                        toY: e.value.toDouble(),
                                        color: Colors.lightBlueAccent,
                                        width: 16,
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Ringkasan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildSummaryItem(
                              'Total Laporan Bulan Ini',
                              attendanceData[DateTime.now().month - 1]
                                  .toString()),
                          _buildSummaryItem(
                              'Rata-rata Laporan Bulanan',
                              (attendanceData.reduce((a, b) => a + b) /
                                      attendanceData.length)
                                  .toStringAsFixed(1)),
                          _buildSummaryItem('Laporan Tertinggi Bulanan',
                              '${attendanceData.reduce((a, b) => a > b ? a : b)} pada ${_getMonthName(attendanceData.indexOf(attendanceData.reduce((a, b) => a > b ? a : b)))}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Card(
      elevation: 5.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
        ),
      ),
    );
  }

  String _getMonthName(int monthIndex) {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[monthIndex];
  }
}
