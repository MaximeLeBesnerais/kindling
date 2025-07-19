
import 'package:flutter/material.dart';

class ArchiveScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archive'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text('Archived Topics'),
      ),
    );
  }
}
