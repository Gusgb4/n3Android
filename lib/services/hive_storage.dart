import 'package:hive/hive.dart';
import '../models/attendance.dart';

class HiveStorage {
  static final Box box = Hive.box('appBox');

  // ============================
  // PERFIL

  static void saveProfile(String id, String name, String deviceId) {
    box.put('profile', {
      'id': id,
      'name': name,
      'deviceId': deviceId,
    });
  }

  static Map<String, dynamic>? getProfile() {
    final raw = box.get('profile');
    if (raw == null) return null;

    // converte para o tipo correto
    return Map<String, dynamic>.from(raw);
  }

  // ============================
  // PRESENÇAS

  static void saveAttendance(Attendance a) {
    final raw = box.get('attendances', defaultValue: []);

    // garante lista mutável e tipada
    final List<Map<String, dynamic>> list = raw
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();

    list.add({
      'id': a.studentId,
      'name': a.studentName,
      'date': a.recordedAt.toIso8601String(),
      'round': a.roundIndex,
      'status': a.status,
      'validation': a.validationMethod,
    });

    box.put('attendances', list);
  }

  static List<Attendance> loadAttendances() {
    final raw = box.get('attendances', defaultValue: []);

    if (raw is! List) return [];

    final list = raw
        .whereType<Map>() // garante tipo Map
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return list.map((e) {
      return Attendance(
        studentId: e['id'],
        studentName: e['name'],
        recordedAt: DateTime.tryParse(e['date']) ?? DateTime.now(),
        roundIndex: e['round'],
        status: e['status'],
        validationMethod: e['validation'],
      );
    }).toList();
  }
}
