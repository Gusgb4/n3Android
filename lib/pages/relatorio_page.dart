import 'package:flutter/material.dart';
import '../controllers/app_state.dart';

class RelatorioPage extends StatelessWidget {
  final AppState app;
  const RelatorioPage({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    final csv = app.buildCsv();
    return Scaffold(
      appBar: AppBar(title: const Text('Relatório / CSV')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pré-visualização CSV', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(child: SingleChildScrollView(child: SelectableText(csv))),
            const SizedBox(height: 12),
            const Text('Obs.: Na N2, apenas especificamos o layout. Na N3, salvar/compartilhar.'),
          ],
        ),
      ),
    );
  }
}
