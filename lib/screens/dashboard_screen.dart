import 'package:flutter/material.dart';
import 'create_pool_screen.dart';
import 'pool_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  bool isLoading = true;

  List<Map<String, dynamic>> pools = [
    {
      "name": "Goa Trip Pool",
      "collected": 16000,
      "target": 20000
    }
  ];

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void addPool(Map<String, dynamic> newPool) {
    setState(() {
      pools.add(newPool);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () async {

          final newPool = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePoolScreen(),
            ),
          );

          if (newPool != null) {
            addPool(newPool);
          }
        },
      ),

      body: Stack(
        children: [

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 40),

                const Text(
                  "Welcome back 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Small contributions build big dreams.",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1554224155-6726b3ff858f",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Active Pools",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pools.length,
                  itemBuilder: (context, index) {

                    var pool = pools[index];
                    double progress = pool["collected"] / pool["target"];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PoolDetailsScreen(
  pool: pool,
),
                          ),
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              pool["name"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text("₹${pool["collected"]} / ₹${pool["target"]}"),

                            const SizedBox(height: 10),

                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              color: Colors.black,
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ),

              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Icon(
                      Icons.account_balance_wallet,
                      size: 80,
                      color: Colors.black,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "GatherPay",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const CircularProgressIndicator(
                      color: Colors.black,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Loading your pools...",
                      style: TextStyle(color: Colors.grey),
                    )

                  ],
                ),
              ),
            )

        ],
      ),
    );
  }
}