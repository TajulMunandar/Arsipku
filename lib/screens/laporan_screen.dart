import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/surat_service.dart';

class LaporanScreen extends StatefulWidget {
  @override
  _LaporanScreenState createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final SuratService _suratService = SuratService.instance;
  int jumlahSuratMasuk = 0;
  int jumlahSuratKeluar = 0;
  double persenMasuk = 0;
  double persenKeluar = 0;

  @override
  void initState() {
    super.initState();
    _ambilDataSurat();
  }

  Future<void> _ambilDataSurat() async {
    // Ambil list jumlah per hari selama 7 hari terakhir
    List<int> masukList = await _suratService.getJumlahSuratPerHari("masuk");
    List<int> keluarList = await _suratService.getJumlahSuratPerHari("keluar");

    int totalMasuk = masukList.fold(0, (sum, item) => sum + item);
    int totalKeluar = keluarList.fold(0, (sum, item) => sum + item);
    int total = totalMasuk + totalKeluar;

    setState(() {
      jumlahSuratMasuk = totalMasuk;
      jumlahSuratKeluar = totalKeluar;
      persenMasuk = total == 0 ? 0 : (totalMasuk / total) * 100;
      persenKeluar = total == 0 ? 0 : (totalKeluar / total) * 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan"),
        backgroundColor: Colors.blueAccent,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Laporan Surat Mingguan",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey),
                          ),
                          SizedBox(height: 20),
                          _infoCard(
                              "Surat Masuk", jumlahSuratMasuk, Colors.blue),
                          SizedBox(height: 10),
                          _infoCard(
                              "Surat Keluar", jumlahSuratKeluar, Colors.green),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(width: 600, child: _buildChart()),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Laporan Surat Mingguan",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey),
                            ),
                            SizedBox(height: 20),
                            _infoCard(
                                "Surat Masuk", jumlahSuratMasuk, Colors.blue),
                            SizedBox(height: 10),
                            _infoCard("Surat Keluar", jumlahSuratKeluar,
                                Colors.green),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildChart(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _infoCard(String title, int count, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(Icons.mail, color: color, size: 40),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text("$count Surat", style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
              toY: persenMasuk,
              color: Colors.blue,
              width: 30,
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            )
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(
              toY: persenKeluar,
              color: Colors.green,
              width: 30,
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreenAccent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            )
          ]),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) =>
                  Text("${value.toInt()}%", style: TextStyle(fontSize: 12)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value == 1 ? "Surat Masuk" : "Surat Keluar",
                  style: TextStyle(fontSize: 12),
                );
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
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barTouchData: BarTouchData(enabled: true),
        maxY: 100,
      ),
    );
  }
}
