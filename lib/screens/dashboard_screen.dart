import 'package:flutter/material.dart';
import 'create_pool_screen.dart';
import 'pool_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Simulate loading delay (API / images)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreatePoolScreen()),
          );
        },
      ),

      body: Stack(
        children: [

          /// DASHBOARD CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 40),

                /// Welcome
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

                /// Banner Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1554224155-6726b3ff858f",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,

                    /// When image loads → remove loader
                    loadingBuilder: (context, child, progress) {

                      if (progress == null) {
                        Future.microtask(() {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        });
                        return child;
                      }

                      return Container(
                        height: 180,
                        color: Colors.grey[200],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                /// Active Pools
                const Text(
                  "Active Pools",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                /// Pool Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PoolDetailsScreen()),
                    );
                  },

                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Goa Trip Pool",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text("₹16000 / ₹20000"),

                        const SizedBox(height: 10),

                        LinearProgressIndicator(
                          value: 0.8,
                          backgroundColor: Colors.grey[300],
                          color: Colors.black,
                        ),

                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),

          /// GATHERPAY LOADING OVERLAY
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