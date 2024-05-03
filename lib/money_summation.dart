
import 'package:intl/intl.dart';

class MoneySummation {
  static const Map<String, double> philippineCurrency = {
    '020': 20.0,
    '1': 1.0,
    '10': 10.0,
    '100': 100.0,
    '1000': 1000.0,
    '20': 20.0,
    '200': 200.0,
    '25': 0.25,
    '5': 5.0,
    '50': 50.0,
    '500': 500.0,
  };

  static double sumPhilippineMoney(List<dynamic> detections) {
    double total = 0.0;

    for (var detection in detections) {
      if (detection['detectedClass'] != null &&
          philippineCurrency.containsKey(detection['detectedClass'])) {
        total += philippineCurrency[detection['detectedClass']]!;
      }
    }

    return total;
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
    return formatter.format(amount);
  }
}

  

//   import 'package:intl/intl.dart';

// class MoneySummation {
//   static bool isMoney(String className) {
//     List<String> moneyClasses = [
//       '020', '1', '10', '100', '1000',
//       '20', '200', '25', '5', '50', '500'
//     ];
//     return moneyClasses.contains(className);
//   }

//   static double extractMoneyValue(String className) {
//     Map<String, double> moneyMappings = {
//       '020': 20.0, '1': 1.0, '10': 10.0, '100': 100.0, '1000': 1000.0,
//       '20': 20.0, '200': 200.0, '25': 0.25, '5': 5.0, '50': 50.0, '500': 500.0
//     };
//     return moneyMappings[className] ?? 0.0;
//   }

//   static Future<Map<String, dynamic>> sumDetectedMoney(List<dynamic> output, List<String> names, double threshold) async {
//     double totalMoneySum = 0.0;

//     for (int i = 0; i < output.length; i++) {
//       if (output[i][6] > threshold && isMoney(names[output[i][5].toInt()])) {
//         totalMoneySum += extractMoneyValue(names[output[i][5].toInt()]);
//       }
//     }

//     final NumberFormat formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
//     String formattedTotal = formatter.format(totalMoneySum);

//     return {
//       'totalSum': totalMoneySum,
//       'formattedTotal': formattedTotal,
//     };
//   }
// }
