import 'package:flutter/material.dart';
import '../services/surat_service.dart';
import '../models/surat_model.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class SuratKeluarScreen extends StatefulWidget {
  const SuratKeluarScreen({super.key});

  @override
  _SuratKeluarScreenState createState() => _SuratKeluarScreenState();
}

class _SuratKeluarScreenState extends State<SuratKeluarScreen> {
  final SuratService _suratService = SuratService.instance;

  void _pilihFile(Function(String) onFilePicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      Directory appDir = await getApplicationDocumentsDirectory();
      String newPath = "${appDir.path}/${result.files.single.name}";
      await file.copy(newPath);

      onFilePicked(newPath); // Kembalikan path file ke form
    }
  }

  void _tambahAtauEditSurat({Surat? surat}) async {
    TextEditingController nomorController =
        TextEditingController(text: surat?.nomorSurat ?? '');
    TextEditingController pengirimController =
        TextEditingController(text: surat?.pengirim ?? '');
    TextEditingController penerimaController =
        TextEditingController(text: surat?.penerima ?? '');
    TextEditingController perihalController =
        TextEditingController(text: surat?.perihal ?? '');
    TextEditingController fileController =
        TextEditingController(text: surat?.fileUrl ?? '');

    DateTime? selectedDate =
        surat != null ? DateTime.tryParse(surat.tanggalSurat) : null;
    TextEditingController tanggalController = TextEditingController(
      text: selectedDate != null
          ? "${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}"
          : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(surat == null ? "Tambah Surat Keluar" : "Edit Surat"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nomorController,
                    decoration: InputDecoration(labelText: "Nomor Surat")),
                TextField(
                    controller: pengirimController,
                    decoration: InputDecoration(labelText: "Pengirim")),
                TextField(
                    controller: penerimaController,
                    decoration: InputDecoration(labelText: "Penerima")),
                TextField(
                    controller: perihalController,
                    decoration: InputDecoration(labelText: "Perihal")),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        tanggalController.text =
                            "${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: tanggalController,
                      decoration: InputDecoration(labelText: "Tanggal Surat"),
                    ),
                  ),
                ),
                TextField(
                  controller: fileController,
                  decoration: InputDecoration(labelText: "File Surat"),
                  readOnly: true,
                ),
                ElevatedButton(
                  onPressed: () {
                    _pilihFile((path) {
                      fileController.text = path;
                    });
                  },
                  child: Text("Pilih File"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Batal")),
            ElevatedButton(
              onPressed: () async {
                Surat newSurat = Surat(
                  jenisSurat: "keluar",
                  id: surat?.id, // tambahkan ini!
                  nomorSurat: nomorController.text,
                  pengirim: pengirimController.text,
                  penerima: penerimaController.text,
                  perihal: perihalController.text,
                  tanggalSurat: tanggalController.text,
                  fileUrl: fileController.text,
                  status: surat?.status ?? "diproses",
                );

                if (surat == null) {
                  await _suratService.tambahSurat(newSurat);
                } else {
                  await _suratService.editSurat(newSurat);
                }

                Navigator.pop(context);
                setState(() {});
              },
              child: Text(surat == null ? "Simpan" : "Update"),
            ),
          ],
        );
      },
    );
  }

  void _hapusSurat(int id) async {
    await _suratService.hapusSurat(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Surat Keluar"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Surat>>(
        future: _suratService.getSurat("keluar"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Tidak ada surat keluar"));
          }

          List<Surat> suratList = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("No")),
                DataColumn(label: Text("Tanggal")),
                DataColumn(label: Text("Nomor Surat")),
                DataColumn(label: Text("Pengirim")),
                DataColumn(label: Text("Penerima")),
                DataColumn(label: Text("Perihal")),
                DataColumn(label: Text("File")),
                DataColumn(label: Text("Aksi")),
              ],
              rows: List<DataRow>.generate(suratList.length, (index) {
                Surat surat = suratList[index];
                return DataRow(cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(surat.tanggalSurat)),
                  DataCell(Text(surat.nomorSurat)),
                  DataCell(Text(surat.pengirim)),
                  DataCell(Text(surat.penerima)),
                  DataCell(Text(surat.perihal)),
                  DataCell(surat.fileUrl.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.attach_file, color: Colors.green),
                          onPressed: () {
                            File file = File(surat.fileUrl);
                            if (file.existsSync()) {
                              OpenFile.open(file.path);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("File tidak ditemukan")),
                              );
                            }
                          },
                        )
                      : Text("-")),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _tambahAtauEditSurat(surat: surat),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusSurat(surat.id as int),
                      ),
                    ],
                  )),
                ]);
              }),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tambahAtauEditSurat(),
        child: Icon(Icons.add),
      ),
    );
  }
}
