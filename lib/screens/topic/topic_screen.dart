import 'package:flutter/material.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Current Topics'),
      ),
    );
  }
}