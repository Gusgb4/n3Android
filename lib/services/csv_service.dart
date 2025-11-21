import '../models/attendance.dart';

class CsvService {
  String buildCsv(Iterable<Attendance> data) {
    final b = StringBuffer();
    b.writeln('student_id,student_name,date,round,status,recorded_at,validation_method,notes');
    for (final a in data) {
      final date = '${a.recordedAt.year.toString().padLeft(4, '0')}-${a.recordedAt.month.toString().padLeft(2, '0')}-${a.recordedAt.day.toString().padLeft(2, '0')}';
      final iso = a.recordedAt.toIso8601String();
      b.writeln('${a.studentId},"${a.studentName}",$date,${a.roundIndex},${a.status},$iso,"${a.validationMethod}","${a.notes.replaceAll('"', "''")}"');
    }
    return b.toString();
  }
}
