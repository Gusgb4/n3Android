enum RoundState { notStarted, active, finished }

class RoundInfo {
  final int index; // 1..4
  DateTime? start;
  DateTime? end;
  RoundState state;

  RoundInfo({required this.index, this.start, this.end, this.state = RoundState.notStarted});
}
