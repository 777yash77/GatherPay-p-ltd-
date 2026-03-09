import 'dart:async';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    /// Simulate loading
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            RotationTransition(
              turns: controller,
              child: const Icon(
                Icons.refresh,
                size: 40,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Loading your pools...",
              style: TextStyle(color: Colors.grey),
            )

          ],
        ),
      ),
    );
  }
}