import 'dart:async';

typedef RoundTick = void Function(int roundIndex, Duration remainingActive);
typedef RoundEvent = void Function(String message);

class SimClock {
  final Duration durationRoundActive; // janela ativa da rodada
  final Duration durationBetweenRounds; // intervalo até próxima rodada
  final int roundsPerNight;

  SimClock({
    required this.durationRoundActive,
    required this.durationBetweenRounds,
    required this.roundsPerNight,
  });

  bool _running = false;
  bool get isRunning => _running;

  /// Executa as 4 rodadas automaticamente, chamando callbacks.
  Future<void> runNight({
    required Future<void> Function(int roundIndex) onRoundStart,
    required Future<void> Function(int roundIndex) onRoundFinish,
    required RoundTick onTick,
    RoundEvent? onEvent,
  }) async {
    if (_running) return;
    _running = true;

    for (int i = 1; i <= roundsPerNight; i++) {
      await onRoundStart(i);
      onEvent?.call('Rodada $i iniciada');

      final start = DateTime.now();
      while (DateTime.now().difference(start) < durationRoundActive) {
        final remaining = durationRoundActive - DateTime.now().difference(start);
        onTick(i, remaining);
        await Future.delayed(const Duration(milliseconds: 200));
      }

      await onRoundFinish(i);
      onEvent?.call('Rodada $i encerrada');

      if (i < roundsPerNight) {
        await Future.delayed(durationBetweenRounds);
      }
    }

    _running = false;
  }
}
