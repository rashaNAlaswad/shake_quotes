import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'quote_display.dart';
import 'quotes_manager.dart';

class ShakeQuoteScreen extends StatefulWidget {
  const ShakeQuoteScreen({super.key});

  @override
  State<ShakeQuoteScreen> createState() => _ShakeQuoteScreenState();
}

class _ShakeQuoteScreenState extends State<ShakeQuoteScreen> {
  static const EventChannel _eventChannel = EventChannel('shake_events');
  StreamSubscription<dynamic>? _shakeSubscription;

  final List<String> _quotes = QuotesManager.quotes;
  String? _currentQuote;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        setState(() {
          _quotes.shuffle();
          _currentQuote = _quotes.first;
        });
      },
      onError: (dynamic error) {
        print('Error receiving shake events: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.purple.shade400],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...[
                const Icon(Icons.phone_android, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Shake your phone',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'to get a motivational quote!',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              _currentQuote != null
                  ? QuoteDisplay(quote: _currentQuote!)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    super.dispose();
  }
}
