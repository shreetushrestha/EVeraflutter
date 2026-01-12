import 'package:flutter/material.dart';
import '../services/station_service.dart';

class ManagerPage extends StatelessWidget {
  const ManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Stations")),
      body: FutureBuilder(

        future: StationService().getMyStations(),
        
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final stations = snapshot.data as List<Map<String, dynamic>>;

          return ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(stations[index]['name']),
                subtitle: Text(stations[index]['city']),
              );
            },
          );
        },
      ),
    );
  }
}
