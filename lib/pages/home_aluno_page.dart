import 'package:flutter/material.dart';
import '../controllers/app_state.dart';

class HomeAlunoPage extends StatefulWidget {
  final AppState app;
  const HomeAlunoPage({super.key, required this.app});

  @override
  State<HomeAlunoPage> createState() => _HomeAlunoPageState();
}

class _HomeAlunoPageState extends State<HomeAlunoPage> {
  final _name = TextEditingController();
  final _id = TextEditingController();
  int _lastTickShown = -1;

  @override
  void initState() {
    super.initState();
    widget.app.addListener(_onChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.app.startNightIfNeeded();
    });
  }

  void _onChange() {
    // Snackbars de eventos (rodada iniciada/encerrada)
    if (!mounted) return;
    if (widget.app.eventTick != _lastTickShown &&
        widget.app.lastEvent != null) {
      _lastTickShown = widget.app.eventTick;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.app.lastEvent!)),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.app.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final round = widget.app.currentRound;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamada — Aluno'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/historico'),
          ),
          IconButton(
            icon: const Icon(Icons.table_view),
            onPressed: () => Navigator.pushNamed(context, '/relatorio'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.app.hasProfile) ...[
                  const Text('Defina seu perfil para registrar presença',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Seu nome')),
                  TextField(
                      controller: _id,
                      decoration:
                          const InputDecoration(labelText: 'Seu ID/matrícula')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_name.text.isNotEmpty && _id.text.isNotEmpty) {
                        widget.app.setProfile(_id.text, _name.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Preencha nome e ID.')));
                      }
                    },
                    child: const Text('Salvar perfil'),
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  round.index > 0
                      ? 'Rodada ${round.index}'
                      : 'Sem rodada ativa',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                    'Tempo restante: ${widget.app.roundActiveRemaining.inSeconds}s'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (widget.app.isRoundActive && widget.app.hasProfile)
                      ? () async {
                          final msg = await widget.app.confirmPresence();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(msg)));
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(260, 54)),
                  child: const Text('CONFIRMAR PRESENÇA'),
                ),
                const SizedBox(height: 12),
                const Text('Validação de presença por GPS (Até 50m da Sala)'),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: () {
                    // Reinicia a simulação na hora (útil pra testes)
                    widget.app.startNightIfNeeded();
                  },
                  child: const Text('Reiniciar simulação de rodadas'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
