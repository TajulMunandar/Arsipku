import 'package:flutter/material.dart';
import '../services/surat_service.dart';
import '../models/surat_model.dart';
import 'daftar_surat_per_tahun_screen.dart';

class SemuaSuratScreen extends StatefulWidget {
  const SemuaSuratScreen({super.key});

  @override
  State<SemuaSuratScreen> createState() => _SemuaSuratScreenState();
}

class _SemuaSuratScreenState extends State<SemuaSuratScreen> {
  final SuratService _suratService = SuratService.instance;

  late Future<List<String>> _tahunMasuk;
  late Future<List<String>> _tahunKeluar;

  @override
  void initState() {
    super.initState();
    _tahunMasuk = _suratService.getTahunSurat("masuk");
    _tahunKeluar = _suratService.getTahunSurat("keluar");
  }

  Widget _buildYearCards(String title, List<String> tahunList, String jenis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tahunList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          itemBuilder: (context, index) {
            final tahun = tahunList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DaftarSuratPerTahunScreen(
                      jenisSurat: jenis,
                      tahun: tahun,
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.purple.shade100,
                child: Center(
                    child: Text(
                  'Tahun $tahun',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Semua Surat"),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder(
        future: Future.wait([_tahunMasuk, _tahunKeluar]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData)
            return const Center(child: Text("Gagal memuat data surat"));

          final List<String> masukTahun = snapshot.data![0];
          final List<String> keluarTahun = snapshot.data![1];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (masukTahun.isNotEmpty)
                  _buildYearCards("Surat Masuk", masukTahun, "masuk"),
                const SizedBox(height: 24),
                if (keluarTahun.isNotEmpty)
                  _buildYearCards("Surat Keluar", keluarTahun, "keluar"),
              ],
            ),
          );
        },
      ),
    );
  }
}
