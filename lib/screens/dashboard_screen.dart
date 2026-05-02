import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TouristSafe"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // 🔹 Status Card
            Card(
              child: ListTile(
                leading: Icon(Icons.shield, color: Colors.green),
                title: Text("Status"),
                subtitle: Text("Online"),
              ),
            ),

            SizedBox(height: 10),

            // 🔹 Private Mode Toggle
            SwitchListTile(
              title: Text("Private Mode"),
              value: false,
              onChanged: (value) {},
            ),

            SizedBox(height: 10),

            // 🔹 Battery Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Battery"),
                LinearProgressIndicator(value: 0.7),
                Text("70%"),
              ],
            ),

            SizedBox(height: 20),

            // 🔹 Map Preview (dummy)
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Text("Map Preview"),
              ),
            ),

            SizedBox(height: 20),

            // 🔹 SOS Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: Text(
                "SOS",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
