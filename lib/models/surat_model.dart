class Surat {
  final int? id;
  final String jenisSurat;
  final String nomorSurat;
  final String tanggalSurat;
  final String pengirim;
  final String penerima;
  final String perihal;
  final String fileUrl;
  final String status;

  Surat({
    this.id, // Nullable
    required this.jenisSurat,
    required this.nomorSurat,
    required this.tanggalSurat,
    required this.pengirim,
    required this.penerima,
    required this.perihal,
    required this.fileUrl,
    required this.status,
  });

  // Convert Surat object ke Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'jenis_surat': jenisSurat,
      'nomor_surat': nomorSurat,
      'tanggal_surat': tanggalSurat,
      'pengirim': pengirim,
      'penerima': penerima,
      'perihal': perihal,
      'file_url': fileUrl,
      'status': status,
    };

    // Hanya tambahkan ID jika tidak null
    if (id != null) {
      map['id'] = id as int; // Pastikan tetap int
    }

    return map;
  }

  // Convert Map ke Surat object
  factory Surat.fromMap(Map<String, dynamic> map) {
    return Surat(
      id: map['id'] != null
          ? map['id'] as int
          : null, // Auto-increment ID dari SQLite
      jenisSurat: map['jenis_surat'],
      nomorSurat: map['nomor_surat'],
      tanggalSurat: map['tanggal_surat'],
      pengirim: map['pengirim'],
      penerima: map['penerima'],
      perihal: map['perihal'],
      fileUrl: map['file_url'] ?? '',
      status: map['status'],
    );
  }
}
