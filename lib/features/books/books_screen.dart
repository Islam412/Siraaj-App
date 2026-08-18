import 'package:flutter/material.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الكتب')),
      body: const Center(child: Text('شاشة الكتب - قيد التطوير')),
    );
  }
}
