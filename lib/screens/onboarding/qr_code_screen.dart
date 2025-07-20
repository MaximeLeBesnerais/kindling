import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../screen_manager/screen_manager.dart';

class QrCodeScreen extends StatelessWidget {
  final String qrCodeSecret;

  const QrCodeScreen({required this.qrCodeSecret});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan this QR code with your partner\'s device to join the space.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: QrImageView(
                data: qrCodeSecret,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Or share this code manually:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(qrCodeSecret),
                IconButton(
                  icon: Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: qrCodeSecret));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Tooltip(
              message: 'Your partner can join at any time.',
              child: Icon(Icons.info_outline),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ScreenManager()));
              },
              child: Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
