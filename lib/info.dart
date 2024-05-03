// import 'package:flutter/material.dart';

// class AboutPage extends StatefulWidget {
//   const AboutPage({super.key});

//   @override
//   State<AboutPage> createState() => _AboutPageState();
// }

// class _AboutPageState extends State<AboutPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 100,
//         title: Text("About PesoSight",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 30,
//           )
//         ),
//         backgroundColor: Colors.yellow[600],
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back,
//             color: Colors.black,
//             size: 40,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         bottomOpacity: 0.0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(40),
//             bottomRight: Radius.circular(40),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               height: MediaQuery.of(context).size.height * 0.3,
//               child: Center(
//                 child: Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Image.asset('assets/images/pesosightlogo.png')),
//               ),
//             ),
//             Container(
//               height: MediaQuery.of(context).size.height * 0.35, // Add some space between the logo and the text
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Text('PesoSight is a mobile application specifically designed to address the challenges faced by the visually impaired in handling Philippine currency. The application is intended to offer a user-friendly solution, allowing visually impaired users to easily recognize and calculate the total value of their currency with the use of smartphones.',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 24,
//                     ),
//                     textAlign: TextAlign.justify,
//                   ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  double textContainerHeight = 0.45; // Set the initial height of the text container
  final FlutterTts _flutterTts = FlutterTts();

  
  @override
  void initState() {
    super.initState();
    _initTts();
  }

  _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   WidgetsBinding.instance.addPostFrameCallback((_) {
    _speakText();
  });
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text("About PesoSight",
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
          )
        ),
        backgroundColor: Colors.yellow[600],
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
            color: Colors.black,
            size: 40,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottomOpacity: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Center(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset('assets/images/pesosightlogo.png')),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * textContainerHeight, // Use the variable for the height
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('PesoSight is a mobile application specifically designed to assist the challenges faced by the visually impaired in handling Philippine currency. The application is intended to offer a user-friendly solution, allowing visually impaired users to recognize and calculate the total value of their currency with the use of smartphones.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.justify,
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _speakText() async {
  await Future.delayed(Duration(seconds: 3));
  await _flutterTts.speak("About PesoSight. PesoSight is a mobile application specifically designed to assist the challenges faced by the visually impaired in handling Philippine currency. The application is intended to offer a user-friendly solution, allowing visually impaired users to recognize and calculate the total value of their currency with the use of smartphones.");
}

}