import 'package:flutter/material.dart';

class TopicScreen extends StatelessWidget {
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