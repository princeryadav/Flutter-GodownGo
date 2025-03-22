import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:namer_app/config.dart';
import 'package:namer_app/pages/login_page.dart' as login_page;
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _mobileController = TextEditingController();
  LatLng? userLocation;

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _registerUser() async {
    if (_mobileController.text.isEmpty || userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter mobile number and share location')),
      );
      return;
    }
    // Proceed with registration (e.g., send data to API)
    final url = Uri.parse(APIConfig.registerUser);
    final body = jsonEncode({
    // You might want to generate a unique ID or leave it empty
      "mobileNumber": _mobileController.text,
      "location": {
        "latitude": userLocation!.latitude,
        "longitude": userLocation!.longitude
      },
      "registeredAt": DateTime.now().toIso8601String(),
    });
     try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const login_page.LoginScreen()),
        );
      } else if (response.statusCode == 409) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const login_page.LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: ${response.body}')),
        );
      }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Registration')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getLocation,
              child: const Text('Share Location'),
            ),
            if (userLocation != null)
              Text('Location: ${userLocation!.latitude}, ${userLocation!.longitude}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
