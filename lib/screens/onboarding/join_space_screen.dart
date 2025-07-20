import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kindling/screens/screen_manager/screen_manager.dart';
import 'package:kindling/services/api_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../providers/topic_provider.dart';

class JoinSpaceScreen extends StatefulWidget {
  const JoinSpaceScreen({super.key});

  @override
  _JoinSpaceScreenState createState() => _JoinSpaceScreenState();
}

class _JoinSpaceScreenState extends State<JoinSpaceScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _secretController = TextEditingController();
  bool _isScanning = false;

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (mounted && barcodes.barcodes.isNotEmpty) {
      final barcode = barcodes.barcodes.first;
      if (barcode.rawValue != null) {
        _secretController.text = barcode.rawValue!;
        await _joinSpace();
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      }
    }
  }

  Future<void> _joinSpace() async {
    if (_secretController.text.isEmpty) return;
    try {
      await _apiService.joinSpace(_secretController.text);
      if (mounted) {
        await Provider.of<TopicProvider>(context, listen: false).fetchTopics(force: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ScreenManager()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join space: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canScan = Platform.isAndroid || Platform.isIOS;

    return Scaffold(
      appBar: AppBar(title: const Text('Join Space')),
      body: _isScanning
          ? Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: MobileScanner(
                    onDetect: _handleBarcode,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isScanning = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                )
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _secretController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Secret Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _joinSpace,
                    child: const Text('Join Space'),
                  ),
                  const SizedBox(height: 20),
                  if (canScan)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _isScanning = true),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR Code'),
                    ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _secretController.dispose();
    super.dispose();
  }
}
