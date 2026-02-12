import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';

class EsewaService {
  static void pay({
    required int amount,
    required String productName,
    required Function onSuccess,
    required Function onFailure,
  }) {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test, // Change to Environment.production in live
          clientId: "JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R ",
          secretId: "BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ==",
        ),
        esewaPayment: EsewaPayment(
          productId: "EV${DateTime.now().millisecondsSinceEpoch}", // unique id
          productName: productName,
          productPrice: amount.toString(),
          callbackUrl: "", // Optional, for server validation
        ),
        onPaymentSuccess: (data) {
          print("SUCCESS: $data");
          onSuccess();
        },
        onPaymentFailure: (data) {
          print("FAILED: $data");
          onFailure();
        },
        onPaymentCancellation: (data) {
          print("CANCELLED: $data");
          onFailure();
        },
      );
    } catch (e) {
      print("ERROR: $e");
      onFailure();
    }
  }
}

