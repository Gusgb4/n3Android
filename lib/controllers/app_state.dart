import 'dart:collection';
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/student.dart';
import '../models/attendance.dart';
import '../models/round.dart';
import '../services/sim_clock.dart';
import '../services/mock_location_service.dart';
import '../services/csv_service.dart';
import '../services/hive_storage.dart';
import '../services/csv_export_service.dart';

class AppState extends ChangeNotifier {
  final SimClock clock;
  final MockLocationService location;
  final CsvService csv;
  final CsvExportService exporter;

  AppState({
    required this.clock,
    required this.location,
    required this.csv,
  }) : exporter = CsvExportService(csv) {
    // Carregar perfil salvo
    final p = HiveStorage.getProfile();
    if (p != null) {
      _profile = StudentProfile(
        id: p['id'],
        name: p['name'],
        deviceId: p['deviceId'],
      );
    }

    // Carregar presenças salvas
    _attendances.addAll(HiveStorage.loadAttendances());
  }

  StudentProfile? _profile;
  final List<Attendance> _attendances = [];
  final Map<int, RoundInfo> _rounds = {
    for (var i = 1; i <= 4; i++) i: RoundInfo(index: i)
  };
  Duration _roundActiveRemaining = Duration.zero;

  String? _lastEvent;
  int _eventTick = 0;

  StudentProfile? get profile => _profile;
  UnmodifiableListView<Attendance> get attendances =>
      UnmodifiableListView(_attendances);
  UnmodifiableMapView<int, RoundInfo> get rounds =>
      UnmodifiableMapView(_rounds);
  Duration get roundActiveRemaining => _roundActiveRemaining;
  String? get lastEvent => _lastEvent;
  int get eventTick => _eventTick;

  bool get hasProfile => _profile != null;
  bool get isRoundActive => currentRound.state == RoundState.active;

  void setProfile(String id, String name) {
    _profile = StudentProfile(id: id, name: name, deviceId: 'dev_$id');
    HiveStorage.saveProfile(id, name, 'dev_$id');
    notifyListeners();
  }

  Future<void> startNightIfNeeded() async {
    if (clock.isRunning) return;

    for (final r in _rounds.values) {
      r.start = null;
      r.end = null;
      r.state = RoundState.notStarted;
    }
    notifyListeners();

    await clock.runNight(
      onRoundStart: (i) async {
        final r = _rounds[i]!;
        r.start = DateTime.now();
        r.state = RoundState.active;
        notifyListeners();
      },
      onRoundFinish: (i) async {
        final r = _rounds[i]!;
        r.end = DateTime.now();
        r.state = RoundState.finished;
        _roundActiveRemaining = Duration.zero;
        notifyListeners();
      },
      onTick: (i, remaining) {
        _roundActiveRemaining = remaining;
        notifyListeners();
      },
      onEvent: (msg) {
        _lastEvent = msg;
        _eventTick++;
        notifyListeners();
      },
    );
  }

  RoundInfo get currentRound {
    final active = _rounds.values.firstWhere(
      (r) => r.state == RoundState.active,
      orElse: () => RoundInfo(index: -1, state: RoundState.notStarted),
    );
    return active;
  }

  Future<String> confirmPresence() async {
    if (!isRoundActive) return 'Rodada não está ativa.';
    if (_profile == null) return 'Defina seu nome e ID nas Configurações.';

    try {
      final reading = await location.getReading();
      final isInside = await location.isInsideAllowedArea(reading);

      if (!isInside) {
        return 'Fora do perímetro da sala ou localização inválida.';
      }

      final now = DateTime.now();
      final round = currentRound.index;
      final already = _attendances.any(
        (a) => a.studentId == _profile!.id && a.roundIndex == round,
      );
      if (already) return 'Presença já registrada nesta rodada.';

      const status = 'P';
      final entry = Attendance(
        studentId: _profile!.id,
        studentName: _profile!.name,
        recordedAt: now,
        roundIndex: round,
        status: status,
        validationMethod:
            'GPS(lat=${reading.latitude.toStringAsFixed(5)}, lon=${reading.longitude.toStringAsFixed(5)}, acc=${reading.accuracyMeters.toStringAsFixed(1)}m)',
      );

      _attendances.add(entry);
      HiveStorage.saveAttendance(entry);
      notifyListeners();
      return 'Presença confirmada!';
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao validar presença: $e');
      return 'Erro ao acessar localização. Verifique as permissões.';
    }
  }

  String buildCsv() => csv.buildCsv(_attendances);
}
