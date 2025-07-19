
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
            QrImageView(
              data: qrCodeSecret,
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20),
            Text('Share this code with your partner to connect.'),
            SizedBox(height: 10),
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
            SizedBox(height: 10),
            Tooltip(
              message: 'Your partner can join at any time.',
              child: Icon(Icons.info_outline),
            ),
            SizedBox(height: 40),
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
