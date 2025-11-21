import 'package:flutter/material.dart';
import '../controllers/app_state.dart';

class SplashPage extends StatefulWidget {
  final AppState app;
  const SplashPage({super.key, required this.app});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return; // 👈 evita o warning
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
