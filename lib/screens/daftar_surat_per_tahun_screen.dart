import 'package:flutter/material.dart';
import '../services/surat_service.dart';
import '../models/surat_model.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class DaftarSuratPerTahunScreen extends StatelessWidget {
  final String jenisSurat;
  final String tahun;

  const DaftarSuratPerTahunScreen({
    super.key,
    required this.jenisSurat,
    required this.tahun,
  });

  @override
  Widget build(BuildContext context) {
    final SuratService suratService = SuratService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text("Surat $jenisSurat Tahun $tahun"),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<Surat>>(
        future: suratService.getSuratByTahun(jenisSurat, tahun),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada surat"));
          }

          final suratList = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text("No")),
                DataColumn(label: Text("Tanggal")),
                DataColumn(label: Text("Nomor Surat")),
                DataColumn(label: Text("Perihal")),
                DataColumn(label: Text("Pengirim")),
                DataColumn(label: Text("Penerima")),
                DataColumn(label: Text("File")),
              ],
              rows: List.generate(suratList.length, (index) {
                final surat = suratList[index];
                return DataRow(cells: [
                  DataCell(Text("${index + 1}")),
                  DataCell(Text(surat.tanggalSurat)),
                  DataCell(Text(surat.nomorSurat)),
                  DataCell(Text(surat.perihal)),
                  DataCell(Text(surat.pengirim)),
                  DataCell(Text(surat.penerima)),
                  DataCell(
                    surat.fileUrl.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.attach_file,
                                color: Colors.green),
                            onPressed: () {
                              File file = File(surat.fileUrl);
                              if (file.existsSync()) {
                                OpenFile.open(file.path);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("File tidak ditemukan")),
                                );
                              }
                            },
                          )
                        : const Text("-"),
                  ),
                ]);
              }),
            ),
          );
        },
      ),
    );
  }
}
