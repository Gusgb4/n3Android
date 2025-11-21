import 'package:flutter/material.dart';
import '../controllers/app_state.dart';

class ConfiguracoesPage extends StatefulWidget {
  final AppState app;
  const ConfiguracoesPage({super.key, required this.app});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final _name = TextEditingController();
  final _id = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.app.profile != null) {
      _name.text = widget.app.profile!.name;
      _id.text = widget.app.profile!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Perfil do Aluno',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil atualizado!')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Preencha nome e ID.')));
                }
              },
              child: const Text('Salvar'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
                'Rodadas (simulação N2): Ativa: 10s, Intervalo: 15s, Total: 4',
                style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
