import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {

  final mobileController = TextEditingController();

  void sendOTP(BuildContext context) {

    String mobile = mobileController.text.trim();

    if (mobile.length != 10) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Enter a valid 10-digit mobile number"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    /// Later you will call backend OTP API here

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("OTP sent to $mobile"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// Icon
              Icon(
                Icons.lock_reset,
                size: 70,
                color: Colors.black,
              ),

              SizedBox(height: 15),

              /// Title
              Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 5),

              Text(
                "Enter your mobile number to receive OTP",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 40),

              /// Mobile Number Field
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,

                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  prefixIcon: Icon(Icons.phone),
                  counterText: "",
                ),
              ),

              SizedBox(height: 25),

              /// Send OTP Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    sendOTP(context);
                  },
                  child: Text("Send OTP"),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}