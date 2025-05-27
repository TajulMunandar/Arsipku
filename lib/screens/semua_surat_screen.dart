import 'package:flutter/material.dart';
import '../services/surat_service.dart';
import '../models/surat_model.dart';

class SemuaSuratScreen extends StatefulWidget {
  const SemuaSuratScreen({super.key});

  @override
  State<SemuaSuratScreen> createState() => _SemuaSuratScreenState();
}

class _SemuaSuratScreenState extends State<SemuaSuratScreen> {
  final SuratService _suratService = SuratService.instance;

  late Future<List<Surat>> _suratMasuk;
  late Future<List<Surat>> _suratKeluar;

  @override
  void initState() {
    super.initState();
    _suratMasuk = _suratService.getSurat("masuk");
    _suratKeluar = _suratService.getSurat("keluar");
  }

  DataTable _buildTable(String title, List<Surat> suratList) {
    return DataTable(
      columnSpacing: 16,
      columns: const [
        DataColumn(
            label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Tanggal Surat',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Nomor Surat',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text('Perihal', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: List.generate(suratList.length, (index) {
        final surat = suratList[index];
        return DataRow(
          cells: [
            DataCell(Text('${index + 1}')),
            DataCell(Text(surat.tanggalSurat)),
            DataCell(Text(surat.nomorSurat)),
            DataCell(Text(surat.perihal)),
            // Asumsinya tanggalSurat sudah berbentuk String
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Semua Surat"),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_suratMasuk, _suratKeluar]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData)
            return Center(child: Text("Gagal memuat data surat"));

          List<Surat> masuk = snapshot.data![0];
          List<Surat> keluar = snapshot.data![1];

          if (masuk.isEmpty && keluar.isEmpty)
            return Center(child: Text("Tidak ada data surat"));

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (masuk.isNotEmpty) ...[
                  Text("Surat Masuk",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildTable("Surat Masuk", masuk),
                  ),
                  SizedBox(height: 24),
                ],
                if (keluar.isNotEmpty) ...[
                  Text("Surat Keluar",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildTable("Surat Keluar", keluar),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
