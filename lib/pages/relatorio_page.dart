import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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
            const Text(
              'Pré-visualização CSV',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Área de visualização do CSV
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(csv),
              ),
            ),

            const SizedBox(height: 16),

            // Botões de ação
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar CSV'),
                  onPressed: () async {
                    final file = await app.exporter
                        .saveCsvFile(app.attendances.toList());

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('CSV salvo em: ${file.path}'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                  onPressed: () async {
                    final file = await app.exporter
                        .saveCsvFile(app.attendances.toList());

                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text: 'Relatório de presenças gerado pelo aplicativo.',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              'Obs.: Agora na N3, os relatórios são salvos no armazenamento '
              'e podem ser compartilhados.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
