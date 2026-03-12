import 'package:flutter/material.dart';

class ContributeScreen extends StatefulWidget {

  final int remainingAmount;

  const ContributeScreen({super.key, required this.remainingAmount});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {

  final upiController = TextEditingController();
  final amountController = TextEditingController();

  bool paymentDone = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contribute"),
        backgroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Enter UPI ID",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            TextField(
              controller: upiController,
              decoration: const InputDecoration(
                hintText: "example@upi",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Enter Amount",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Max ₹${widget.remainingAmount}",
              ),
            ),

            const SizedBox(height: 30),

            /// PAY BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      paymentDone ? Colors.green : Colors.black,
                  foregroundColor: Colors.white,
                ),

                onPressed: () {

                  setState(() {
                    paymentDone = true;
                  });

                },

                child: Text(
                  paymentDone ? "Payment Successful ✔" : "Pay",
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (paymentDone)
              const Center(
                child: Text(
                  "Contribution added to pool",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )

          ],
        ),
      ),
    );
  }
}