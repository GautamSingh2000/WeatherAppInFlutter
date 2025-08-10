import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:weather_app/screens/ScreenOne.dart';

class ClimateHomeScreen extends StatefulWidget {
  const ClimateHomeScreen({super.key});

  @override
  State<ClimateHomeScreen> createState() => _ClimateHomeScreenState();
}

class _ClimateHomeScreenState extends State<ClimateHomeScreen> {
  @override
  void initState() {
    if(mounted){
      _determinePosition();
    }
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    double lat = position.latitude;
    double lon = position.longitude;
    var apiKey = "0ddcf8e969046e9c2ffbb3670c6aa066";
    var url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': apiKey,
      'units': 'metric',
    });
    print(url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print("Weather data: $jsonResponse");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ScreenOne(
          weatherData: jsonResponse,
        )),
            (Route<dynamic> route) => false, // This clears all previous routes
      );

      // You can now use the weather data as needed
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {

    print("build called _ClimateHomeScreenState");
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
          strokeWidth: 5.0,
        )
      ),
    );
  }
}
