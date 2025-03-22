import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:namer_app/config.dart';
import 'package:namer_app/pages/map_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;

  // Step 1: Send OTP
  Future<void> sendOtp() async {
    setState(() => _isLoading = true);
    String mobileNumber = _phoneController.text;
    String encodedMobileNumber = Uri.encodeComponent(mobileNumber);

    final response = await http.get(
      Uri.parse("${APIConfig.sendOtp}?mobileNumber=$encodedMobileNumber"),  // Using GET with query parameter
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      setState(() => _isOtpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Sent Successfully!")),
      );
      // Do not navigate yet; wait for OTP verification
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP. Try again.")),
      );
    }
  }

  // Step 2: Verify OTP
  Future<void> verifyOtp() async {
    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse(APIConfig.verifyOtp),  // Using the centralized API URL
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "mobileNumber": _phoneController.text,
        "otp": _otpController.text
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Successful!")),
      );
      // Navigate to the MapScreen after successful OTP verification
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Login with OTP", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              if (_isOtpSent)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter OTP",
                    border: OutlineInputBorder(),
                  ),
                ),

              SizedBox(height: 20),

              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _isOtpSent ? verifyOtp : sendOtp,
                      child: Text(_isOtpSent ? "Verify OTP" : "Send OTP"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
