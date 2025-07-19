
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'qr_code_screen.dart';

class SpaceChoiceScreen extends StatelessWidget {
  void _showJoinDialog(BuildContext context) {
    final TextEditingController _codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Partner\'s QR Code'),
          content: TextField(
            controller: _codeController,
            decoration: InputDecoration(hintText: 'QR Code Secret'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = _codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.of(context).pop();
                  try {
                    final data = await ApiService().joinSpace(code);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => QrCodeScreen(qrCodeSecret: data['qr_code_secret']),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to join space: \$e')),
                    );
                  }
                }
              },
              child: Text('Join'),
            ),
          ],
        );
      },
    );
  }
  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _apiService.createSpace().then((data) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => QrCodeScreen(qrCodeSecret: data['qr_code_secret']),
                  ));
                });
              },
              child: Text('Create a new Space'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showJoinDialog(context);
              },
              child: Text('Join a partner\'s Space'),
            ),
          ],
        ),
      ),
    );
  }
}
