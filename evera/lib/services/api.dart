import 'dart:convert';
import 'dart:io' show Platform;
import "package:flutter/foundation.dart" show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

class Api{
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/';
    return 'http://localhost:3000/';
  }

  static addProduct(Map pdata) async{
    print(pdata);

    var url = Uri.parse("${baseUrl}add_product");
    try{
      final res = await http.post(url, body: pdata);

      if(res.statusCode == 200){
        var data = jsonDecode(res.body.toString());
        print(data);
      }else{
        print("failed to get response, status: ${res.statusCode}");
      }
    }
    catch (e){
      debugPrint(e.toString());
    }
  }
}

