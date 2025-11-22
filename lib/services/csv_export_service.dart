import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/attendance.dart';
import 'csv_service.dart';

class CsvExportService {
  final CsvService csv;

  CsvExportService(this.csv);

  Future<File> saveCsvFile(List<Attendance> data) async {
    final csvString = csv.buildCsv(data);

    // Diretório externo privado do app (FUNCIONA)
    final dir = await getExternalStorageDirectory();

    final file = File('${dir!.path}/relatorio_presencas.csv');

    await file.writeAsString(csvString);
    return file;
  }
}
