import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:object_detection/detect_screen.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:object_detection/info.dart';

import 'models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<CameraDescription> cameras;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    setupCameras();
  }

  loadModel(model) async {
    String? res;
      res = await Tflite.loadModel(
        model: "assets/yolov2_tiny.tflite",
        labels: "assets/yolov2_tiny.txt",
      );
    log("$res");
  }

  onSelect(model) {
    loadModel(model);
    final route = MaterialPageRoute(builder: (context) {
      return DetectScreen(cameras: cameras, model: model);
    });
    Navigator.of(context).push(route);
  }

  setupCameras() async {
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      log('Error: $e.code\nError Message: $e.message');
    }
  }

  // initializes tts to say when camera or about page is open
  FlutterTts flutterTts = FlutterTts();
  void speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    flutterTts.speak("You're now accessing pesosight. Tap anywhere to open the camera. Tap the upper right corner to access the information page");
    setupCameras();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      toolbarHeight: 100,
      title: Text("pesosight", 
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          )
        ),
      backgroundColor: Colors.yellow[600], //Color.fromARGB(255, 176, 146, 68),
      actions: [
        IconButton(
          icon: Icon(Icons.info, 
            color: Colors.black,
            size: 50,
          ),
              onPressed: () {
              flutterTts.stop();
              speak("You are now in the information page");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoPage()),
              );
            },
          ),
        ],
        bottomOpacity: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (ModalRoute.of(context)!.settings.name!= '/camera') {
            flutterTts.stop();
            speak("You are now accessing the camera");
            onSelect('yolov7');
          }
        },
        child: Container(
          color: Colors.transparent, // Add this to make the GestureDetector fill the screen
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10,),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/pesosightlogo.png')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
