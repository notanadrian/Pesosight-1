import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:object_detection/money_summation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;


import 'models.dart';

typedef Callback = void Function(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;

  const Camera(this.cameras, this.model, this.setRecognitions, {super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  late IsolateInterpreter _interpreter;
  Uint8List? _paddedImage;
  bool isDetecting = false;

  Future<void> loadInterpreter() async {
    try {
      var interpreterOptions = InterpreterOptions()..threads = 4;
      final interpreter = await Interpreter.fromAsset('assets/yolov7.tflite', options: interpreterOptions); // Load the model from assets
      _interpreter =
        await IsolateInterpreter.create(address: interpreter.address);
      print("Interpreter loaded successfully");
    } catch (e) {
      print("Failed to load the interpreter: $e");
    }
  }

    img.Image drawBoundingBoxWithLabel(
    img.Image image,
    List<double> boundingBox, // [x, y, width, height]
    String className,
    int boxColor,             // RGBA value
    int textColor,            // RGBA value for text
    {int lineWidth = 2}       // Line width for the box
  ) {
    final x = (boundingBox[0] ).toInt();
    final y = (boundingBox[1] ).toInt();
    final width = (boundingBox[2] - x ).toInt();
    final height = (boundingBox[3] - y ).toInt();

    // Draw the bounding box
    img.drawLine(image, x, y, x + width, y, boxColor, thickness: lineWidth);
    img.drawLine(image, x, y + height, x + width, y + height, boxColor, thickness: lineWidth);
    img.drawLine(image, x, y, x, y + height, boxColor, thickness: lineWidth);
    img.drawLine(image, x + width, y, x + width, y + height, boxColor, thickness: lineWidth);

    // Add the class name text above the bounding box
    final font = img.arial_14;
    img.drawString(image, font, x, y - 20, className, color: textColor);
    return image;
    
  }
  List<dynamic> letterbox(img.Image image, {
  Size newSize = const Size(320, 320),
  Color padColor = const Color.fromARGB(255, 114, 114, 114),
  bool auto = true,
  bool scaleUp = true,
  int stride = 32,S
}) {
  int currentWidth = image.width;
  int currentHeight = image.height;

  // Calculate the scaling ratio
  double ratio = math.min(newSize.width / currentWidth, newSize.height / currentHeight);

  if (!scaleUp) {
    ratio = math.min(ratio, 1.0);
  }

  int newUnpaddedWidth = (currentWidth * ratio).round();
  int newUnpaddedHeight = (currentHeight * ratio).round();

  int dw = newSize.width.toInt() - newUnpaddedWidth;
  int dh = newSize.height.toInt() - newUnpaddedHeight;

  if (auto) {
    dw = dw % stride;
    dh = dh % stride;
  }
  dw = dw ~/ 2;
  dh =  dh ~/ 2;
  int padLeft = dw;
  // int padRight = dw - padLeft;
  int padTop = dh;
  // int padBottom = dh - padTop;

  // Resize the image to the new dimensions
  img.Image resizedImage = img.copyResize(
    image,
    width: newUnpaddedWidth,
    height: newUnpaddedHeight,
    interpolation: img.Interpolation.linear
  );

  // Create a new image with the specified padding color
  img.Image paddedImage = img.Image(
    newSize.width.toInt(),
    newSize.height.toInt(),
  );
  

  // Fill the padded image with the specified color
  paddedImage = img.fill(
    paddedImage,
    img.getColor(padColor.red, padColor.green, padColor.blue, padColor.alpha),
  );

  // Copy the resized image onto the center of the padded image
  paddedImage = img.copyInto(
    paddedImage,
    resizedImage,
    dstX: padLeft,
    dstY: padTop,
    blend: false, // Set blend to false to avoid blending issues
  );

  List<List<List<double>>> tensor = List.generate(
    3,
    (i) => List.generate(
      320,
      (j) => List.generate(320, (k) => 0),
    ),
  );

  // Populate the tensor with RGB data
  for (int y = 0; y < 320; y++) {
    for (int x = 0; x < 320; x++) {
      int pixel = paddedImage.getPixel(x, y);
      tensor[0][y][x] = img.getRed(pixel)/255;    // Red channel
      tensor[1][y][x] = img.getGreen(pixel)/255;  // Green channel
      tensor[2][y][x] = img.getBlue(pixel)/255;   // Blue channel
    }
  }

  // Return the padded image as a Uint8List (PNG format)
  return [tensor, ratio, dw,dh];
}

  Future<List<dynamic>> runInference(img.Image image) async {
  
    if (_interpreter == null) return [];
    var ratio = 0.0;
    var dw = 0;
    var dh = 0;
    var batch_images = [];
    // for(var byte in byteList){
        print(image.height);
        print(image.width);
        image = img.copyRotate(image, 90);
        var preprocessing = letterbox(image, auto: false);
        var input = preprocessing[0];
        ratio = preprocessing[1];
        dw = preprocessing[2];
        dh = preprocessing[3];
        batch_images.add(input);
    // }
    print(batch_images.shape);
    // Prepare the output buffer with the expected shape (100, 7)
    var output =  List.generate(
              100,
              (l) => List.filled(7, 0.0), // 16 elements filled with 0.0
            );
    // Run inference
    final stopwatch = Stopwatch(); // Create a stopwatch instance
    stopwatch.start(); // Start the stopwatch
    await _interpreter.run(batch_images, output);
    stopwatch.stop(); // Stop the stopwatch
    print("Time taken: ${stopwatch.elapsed}" );
    List<String> names = ['020',
      '1',
      '10',
      '100',
      '1000',
      '20',
      '200',
      '25',
      '5',
      '50',
      '500',];
    double threshold = 0.4;
    List<dynamic> recognitions = [];
    for(int i =0 ; i < output.length;i++){
      if(output[i][6]>threshold){
        print("Detection: ${
            {
              "b_box": [output[i][1],output[i][2],output[i][3],output[i][4]],
              "score": output[i][6]*100,
              "class": names[output[i][5].toInt()] ,
            }
          }");
        recognitions.add({
          "rect":{
              "x": ((output[i][1]-dw)/ratio)/image.width,
              "y": ((output[i][2]-dh)/ratio)/image.height,
              "w": (((output[i][3]-dw)/ratio) - ((output[i][1]-dw)/ratio))/image.width,
              "h": (((output[i][4]-dh)/ratio) - ((output[i][2]-dh)/ratio))/image.height,
          },
          "detectedClass" :  names[output[i][5].toInt()],
          "confidenceInClass" : output[i][6]
        });
        
      }
    }

    double totalAmount = MoneySummation.sumPhilippineMoney(recognitions);
    String formattedTotalAmount = MoneySummation.formatCurrency(totalAmount);
   
  // FlutterTts flutterTts = FlutterTts();

  //     // Read out the detected money and the total amount
  // List<String> detectedMoney = recognitions.map((recognition) {
  //   return '${recognition['detectedClass']} ${recognition['confidenceInClass']}';
  // }).toList();

  // String detectedMoneyText = 'Detected money: ${detectedMoney.join(', ')}. ';
  // String totalAmountText = 'Total amount: $formattedTotalAmount.';

  // String speechText = '$detectedMoneyText $totalAmountText';

  // await flutterTts.setLanguage('en-US');
  // await flutterTts.setSpeechRate(0.5);
  // await flutterTts.speak(speechText);

    // You can now use the formattedTotalAmount string to display the total amount
    print("Total amount: $formattedTotalAmount");
    
    print(recognitions);
    return recognitions;
  }

  /// Converts a YUV420 CameraImage to an img.Image (RGB format).
Future<img.Image?> convertCameraImageToImage(CameraImage cameraImage) async {
  final width = cameraImage.width;
  final height = cameraImage.height;

  final uvRowStride = cameraImage.planes[1].bytesPerRow;
  final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

  final yPlane = cameraImage.planes[0].bytes;
  final uPlane = cameraImage.planes[1].bytes;
  final vPlane = cameraImage.planes[2].bytes;

  final image = img.Image(width, height);

  var uvIndex = 0;

  for (var y = 0; y < height; y++) {
    var pY = y * width;
    var pUV = uvIndex;

    for (var x = 0; x < width; x++) {
      final yValue = yPlane[pY];
      final uValue = uPlane[pUV];
      final vValue = vPlane[pUV];

      final r = yValue + 1.402 * (vValue - 128);
      final g = yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128);
      final b = yValue + 1.772 * (uValue - 128);

      image.setPixelRgba(x, y, r.toInt(), g.toInt(), b.toInt(), 255);

      pY++;
      if (x % 2 == 1 && uvPixelStride == 2) {
        pUV += uvPixelStride;
      } else if (x % 2 == 1 && uvPixelStride == 1) {
        pUV++;
      }
    }

    if (y % 2 == 1) {
      uvIndex += uvRowStride;
    }
  }
  return image;
}

  @override
  void initState() {
    super.initState();
    loadInterpreter();
    if (widget.cameras.isEmpty) {
      log('No camera is found');
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.veryHigh,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        // Add a delay of 2 seconds before starting the object detection
        // Future.delayed(Duration(seconds: 2), () {
        //   controller.startImageStream((CameraImage img) {
        //     if (!isDetecting) {
        //       isDetecting = true;

        //       int startTime = DateTime.now().millisecondsSinceEpoch;
        //       if(widget.model == 'yolov7'){
        //         convertCameraImageToImage(img).then((image){
        //           runInference(image!).then((recognitions) {
        //             int endTime = DateTime.now().millisecondsSinceEpoch;
        //             log("Detection took ${endTime - startTime}");
        //             widget.setRecognitions(recognitions, img.height, img.width);
        //             isDetecting=false;
        //           });
        //         });
        //       }
        //       else {
        //         Tflite.detectObjectOnFrame(
        //           bytesList: img.planes.map((plane) {
        //             return plane.bytes;
        //           }).toList(),
        //           model: "YOLO",
        //           imageHeight: img.height,
        //           imageWidth: img.width,
        //           imageMean: 0,
        //           imageStd: 255.0,
        //           numResultsPerClass: 1,
        //           threshold: 0.2,
        //         ).then((recognitions) {
        //           int endTime = DateTime.now().millisecondsSinceEpoch;
        //           log("Detection took ${endTime - startTime}");
        //           print(recognitions);
        //           widget.setRecognitions(recognitions!, img.height, img.width);

        //           isDetecting = false;
        //         });
        //       }
        //     }
        //   });
        // });
        int detectionDelay = 1500; // Delay in milliseconds (e.g., 100ms = 10 frames per second)
        controller.startImageStream((CameraImage img) async {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = DateTime.now().millisecondsSinceEpoch;
            if(widget.model == 'yolov7'){
              convertCameraImageToImage(img).then((image){
                runInference(image!).then((recognitions) async {
                  int endTime = DateTime.now().millisecondsSinceEpoch;
                  log("Detection took ${endTime - startTime}");
                  widget.setRecognitions(recognitions, img.height, img.width);
                  isDetecting=false;

                  // Add delay here
                  await Future.delayed(Duration(milliseconds: detectionDelay));
                });
              });
            }
            else {
              Tflite.detectObjectOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                model: "YOLO",
                imageHeight: img.height,
                imageWidth: img.width,
                imageMean: 0,
                imageStd: 255.0,
                numResultsPerClass: 1,
                threshold: 0.2,
              ).then((recognitions) async {
                int endTime = DateTime.now().millisecondsSinceEpoch;
                log("Detection took ${endTime - startTime}");
                print(recognitions);
                widget.setRecognitions(recognitions!, img.height, img.width);

                isDetecting = false;

                // Add delay here
                await Future.delayed(Duration(milliseconds: detectionDelay));
              });
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: Stack(
        children: [
          CameraPreview(controller),
          SizedBox(width: 320, height: 320, child:(_paddedImage != null) ?  Image.memory(_paddedImage!):SizedBox()),
        ],
      ),
    );
  }


}