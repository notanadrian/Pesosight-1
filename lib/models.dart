const String mobilenet = "MobileNet";
const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";
const String posenet = "PoseNet";


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Welcome to',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 22,
//                         ),
//                       ),
//                       Text(
//                         'PesoSight',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const InfoPage()),
//                       );
//                     },
//                     child: const Icon(
//                       Icons.info,
//                       color: Colors.blue,
//                       size: 50,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 50),
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.white.withOpacity(0.3),
//                       spreadRadius: 5,
//                       blurRadius: 7,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Image.asset('images/pesosightlogo.png', width: 350, height: 350),
//               ),
//               const SizedBox(height: 70),
//               GestureDetector(
//                 onTap: () {
//                   if (cameras.isNotEmpty) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => CameraPage(cameras)),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('No camera available.'),
//                       ),
//                     );
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 300,
//                   decoration: BoxDecoration(
//                     color: Colors.blueAccent,
//                     borderRadius: BorderRadius.circular(15.0),
//                   ),
//                   child: const Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.camera_alt_rounded,
//                         color: Colors.white,
//                         size: 150,
//                       ),
//                       Text(
//                         'Start Camera',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 40,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }