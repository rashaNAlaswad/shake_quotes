import 'package:flutter/material.dart';

import 'quote_display.dart';
import 'quotes_manager.dart';

class ShakeQuoteScreen extends StatefulWidget {
  const ShakeQuoteScreen({super.key});

  @override
  State<ShakeQuoteScreen> createState() => _ShakeQuoteScreenState();
}

class _ShakeQuoteScreenState extends State<ShakeQuoteScreen> {
  final List<String> _quotes = QuotesManager.quotes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.purple.shade400],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.phone_android, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Shake your phone',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'to get a motivational quote!',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            QuoteDisplay(quote: _quotes.first),
          ],
        ),
      ),
    );
  }
}
