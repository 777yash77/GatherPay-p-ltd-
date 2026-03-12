import 'package:flutter/material.dart';

class PoolDetailsScreen extends StatefulWidget {

  final Map<String, dynamic> pool;

  const PoolDetailsScreen({super.key, required this.pool});

  @override
  State<PoolDetailsScreen> createState() => _PoolDetailsScreenState();
}

class _PoolDetailsScreenState extends State<PoolDetailsScreen> {

  late String poolName;
  late int targetAmount;
  late int collected;

  String admin = "Rahul";

  List<Map<String, dynamic>> members = [
    {"name": "Rahul", "amount": 200},
    {"name": "Arun", "amount": 5000},
    {"name": "Vikram", "amount": 1000},
    {"name": "Karthik", "amount": 0},
  ];

  @override
  void initState() {
    super.initState();

    poolName = widget.pool["name"];
    targetAmount = widget.pool["target"];
    collected = widget.pool["collected"];
  }

  @override
  Widget build(BuildContext context) {

    double progress = collected / targetAmount;

    int perPersonAmount = targetAmount ~/ members.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pool Details"),
        backgroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Pool Name
            Text(
              poolName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            /// Pool Progress
            LinearProgressIndicator(
              value: progress,
              color: Colors.black,
              backgroundColor: Colors.grey[300],
            ),

            const SizedBox(height: 10),

            Text(
              "₹$collected / ₹$targetAmount",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

          ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
  onPressed: () {},
  child: const Text("Contribute Money"),
),

            const SizedBox(height: 30),

            /// Admin Section
            const Text(
              "Admin",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(
                  admin[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(admin),
              subtitle: const Text("Pool Creator"),
            ),

            const SizedBox(height: 25),

            /// Members Section
            const Text(
              "Members Contributions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Column(
              children: members.map((member) {

                int paid = member["amount"];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: ListTile(

                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text(
                        member["name"][0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    title: Text(member["name"]),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("₹$paid / ₹$perPersonAmount"),

                        const SizedBox(height: 6),

                        LinearProgressIndicator(
                          value: paid / perPersonAmount,
                          backgroundColor: Colors.grey[300],
                          color: Colors.black,
                        ),
                      ],
                    ),

                    trailing: Icon(
                      paid >= perPersonAmount
                          ? Icons.check_circle
                          : Icons.pending,
                      color: paid >= perPersonAmount
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                );

              }).toList(),
            )

          ],
        ),
      ),
    );
  }
}