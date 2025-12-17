import 'package:flutter/material.dart';
import 'services/api.dart';
import 'package:dio/dio.dart';

class CreateData extends StatefulWidget {
  const CreateData({super.key});

  @override
  State<CreateData> createState() => _CreateDataState();
}

class _CreateDataState extends State<CreateData> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descController = TextEditingController();

  Dio dio = Dio();
  String result = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // GET request
  Future<void> fetchData() async {
    try {
      final response = await dio.get("${Api.baseUrl}api/v1/users");
      setState(() {
        result = response.data.toString();
      });
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Data"),
        backgroundColor: Colors.blue,
      ),

      // ⭐ FIXED: Scrollable Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // PRODUCT NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Product Name",
                hintText: "Name here",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // PRICE
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: "Price",
                hintText: "Price here",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "Desc here",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // SUBMIT BUTTON
            Center(
              child: ElevatedButton(
                onPressed: () {
                  var data = {
                    "pname": nameController.text,
                    "pprice": priceController.text,
                    "pdesc": descController.text,
                  };

                  Api.addProduct(data);
                },
                child: const Text("Create Data"),
              ),
            ),

            const SizedBox(height: 20),

            // RESULT FROM API
            Text(
              result,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // TEST TEXT
            const Text(
              "hello world",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
