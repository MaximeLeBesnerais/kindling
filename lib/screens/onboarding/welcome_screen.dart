

import 'package:flutter/material.dart';
import 'space_choice_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final String username;

  const WelcomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 8,
              margin: EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Welcome, $username!',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Let\'s get your space ready.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SpaceChoiceScreen()));
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

