import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/bndbox.dart';
import 'package:object_detection/camera.dart';
import 'package:object_detection/money_summation.dart';
import 'dart:math' as math;

import 'package:flutter_tts/flutter_tts.dart';

class DetectScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String model;

  const DetectScreen({super.key, required this.cameras, required this.model});

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  double _totalAmount = 0.0;
  final FlutterTts _flutterTts = FlutterTts();

  setRecognitions(recognitions, imageHeight, imageWidth) async {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
      _totalAmount = MoneySummation.sumPhilippineMoney(recognitions);
    });
      await readAloud();
  }

  // text to speech
  // Future<void> readAloud() async {
  //   String detectedMoneyText = "Detected money: ";
  //     if (_recognitions == null || _recognitions!.isEmpty) {
  //   // Return if there are no detected objects
  //   return;
  // }
  //   for (int i = 0; i < _recognitions!.length; i++) {
  //     detectedMoneyText += "${_recognitions![i]['detectedClass'].replaceAll('PHP ', '')}, ";
  //   }
  //   detectedMoneyText = detectedMoneyText.substring(0, detectedMoneyText.length - 2);
  //   await _flutterTts.speak(detectedMoneyText);

  //   // Wait for the _flutterTts.speak method to complete before adding the delay
  //   await _flutterTts.awaitSpeakCompletion(true);

  //   // Add a delay of 2 seconds before reading the total summation
  //   await Future.delayed(Duration(seconds: 1));

  //   await _flutterTts.speak("Total amount detected: ${MoneySummation.formatCurrency(_totalAmount)}");
  // }

    static const Map<String, String> currencyText = {
    '020': 'twenty',
    '1': 'one',
    '10': 'ten',
    '100': 'one hundred',
    '1000': 'one thousand',
    '20': 'twenty',
    '200': 'two hundred',
    '25': 'twenty-five cents',
    '5': 'five',
    '50': 'fifty',
    '500': 'five hundred',
  };

    Future<void> readAloud() async {
    String detectedMoneyText = "Detected money: ";
    if (_recognitions == null || _recognitions!.isEmpty) {
      // Return if there are no detected objects
      return;
    }
    for (int i = 0; i < _recognitions!.length; i++) {
      final detectedClass = _recognitions![i]['detectedClass'].replaceAll('PHP ', '');
      detectedMoneyText += "${currencyText[detectedClass]}, ";
    }
    detectedMoneyText = detectedMoneyText.substring(0, detectedMoneyText.length - 2);
    await _flutterTts.speak(detectedMoneyText);

    // Wait for the _flutterTts.speak method to complete before adding the delay
    _flutterTts.awaitSpeakCompletion(true);

    // Add a delay of 2 seconds before reading the total summation
    await Future.delayed(Duration(seconds: 1));

    await _flutterTts.speak("Total amount detected: ${MoneySummation.formatCurrency(_totalAmount)}");

    _flutterTts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Camera(
            widget.cameras,
            widget.model,
            setRecognitions,
          ),
          BndBox(
              _recognitions ?? [],
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
              widget.model),
          DetectedMoneyWidget(
            recognitions: _recognitions ?? [],
            totalAmount: _totalAmount,
          ),
        ],
      ),
    );
  }
}

// displays money text on phone screen
class DetectedMoneyWidget extends StatelessWidget {
  final List<dynamic> recognitions;
  final double totalAmount;

  DetectedMoneyWidget({required this.recognitions, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: ${MoneySummation.formatCurrency(totalAmount)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

}