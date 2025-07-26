import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kindling/screens/onboarding/qr_code_screen.dart';
import 'package:kindling/screens/screen_manager/screen_manager.dart';
import 'package:kindling/services/api_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/topic_provider.dart';

class SpaceChoiceScreen extends StatefulWidget {
  const SpaceChoiceScreen({super.key});

  @override
  SpaceChoiceScreenState createState() => SpaceChoiceScreenState();
}

class SpaceChoiceScreenState extends State<SpaceChoiceScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _secretController = TextEditingController();
  bool _isJoinExpanded = false;
  bool _isScanning = false;

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (mounted && barcodes.barcodes.isNotEmpty) {
      final barcode = barcodes.barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _secretController.text = barcode.rawValue!;
          _isScanning = false;
        });
        await _joinSpace();
      }
    }
  }

  Future<void> _joinSpace() async {
    if (_secretController.text.isEmpty) return;
    try {
      await _apiService.joinSpace(_secretController.text);
      if (mounted) {
        await Provider.of<TopicProvider>(context, listen: false).fetchTopics(force: true);
      }
      if (mounted) {
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
      appBar: AppBar(
        title: const Text('Welcome'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final spaceData = await _apiService.createSpace();
                      final secret = spaceData['qr_code_secret'];
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => QrCodeScreen(qrCodeSecret: secret),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create space: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Create a New Space'),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isJoinExpanded = !_isJoinExpanded;
                      _isScanning = false; // Reset scanning state
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Join an Existing Space'),
                ),
                if (_isJoinExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: [
                        if (_isScanning)
                          SizedBox(
                            height: 300,
                            child: MobileScanner(onDetect: _handleBarcode),
                          ),
                        if (!_isScanning)
                          TextField(
                            controller: _secretController,
                            decoration: const InputDecoration(
                              labelText: 'Enter Secret Code',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (canScan)
                              ElevatedButton.icon(
                                onPressed: () => setState(() => _isScanning = !_isScanning),
                                icon: Icon(_isScanning ? Icons.close : Icons.qr_code_scanner),
                                label: Text(_isScanning ? 'Cancel' : 'Scan QR'),
                              ),
                            ElevatedButton(
                              onPressed: _joinSpace,
                              child: const Text('Join'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
