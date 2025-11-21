import 'package:flutter/material.dart';
import '../controllers/app_state.dart';

class HistoricoPage extends StatefulWidget {
  final AppState app;
  const HistoricoPage({super.key, required this.app});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  @override
  void initState() {
    super.initState();
    widget.app.addListener(_onChange);
  }
  void _onChange() => setState((){});
  @override
  void dispose() {
    widget.app.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.app.attendances.toList()
      ..sort((x,y)=>x.recordedAt.compareTo(y.recordedAt));
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico / Diário')),
      body: ListView.builder(
        itemCount: a.length,
        itemBuilder: (_, i) {
          final e = a[i];
          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('${e.studentName} — Rodada ${e.roundIndex} — ${e.status}'),
            subtitle: Text('${e.recordedAt.toIso8601String()}\n${e.validationMethod}'),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
