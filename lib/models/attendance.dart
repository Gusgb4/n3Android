class Attendance {
  final String studentId;
  final String studentName;
  final DateTime recordedAt;
  final int roundIndex;
  final String status; // P=Presente, A=Atrasado, F=Falta
  final String validationMethod;
  final String notes;

  Attendance({
    required this.studentId,
    required this.studentName,
    required this.recordedAt,
    required this.roundIndex,
    required this.status,
    required this.validationMethod,
    this.notes = '',
  });
}
