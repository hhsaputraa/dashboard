import 'package:flutter/material.dart';

class KodeKolScreen extends StatelessWidget {
  const KodeKolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Kode KOL',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
