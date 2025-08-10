import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'SearchCity.dart';

class ScreenOne extends StatefulWidget {
  final weatherData;
  ScreenOne({super.key, this.weatherData});

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {

  late var weatherEmoji;
  late String temp;
  late String cityName;
  late String weatherType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateUi(widget.weatherData);
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
      _updateUi(jsonResponse);
      setState(() {
        isLoading = false;
      });
      // You can now use the weather data as needed
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  String kelvinToCelsius(double kelvin) {
    double celsius = kelvin - 273.15;
    return "${celsius.toStringAsFixed(2)} °C";
  }

  void _updateUi(weatherData) {
        var weatherId = weatherData['weather'][0]['id'];
        if (weatherId >= 200 && weatherId < 300) {
          setState(() {
            weatherEmoji = "⛈️"; // Thunderstorm
          });
          print("Weather is stormy");
        } else if (weatherId >= 300 && weatherId < 400) {
          setState(() {
            weatherEmoji = "🌦️"; // Drizzle
          });
          print("Weather is drizzling");
        } else if (weatherId >= 500 && weatherId < 600) {
          setState(() {
            weatherEmoji = "🌧️"; // Rain
          });
          print("Weather is raining");
        } else if (weatherId >= 600 && weatherId < 700) {
          setState(() {
            weatherEmoji = "❄️"; // Snow
          });
          print("Weather is snowing");
        } else if (weatherId >= 700 && weatherId < 800) {
          setState(() {
            weatherEmoji = "☀️"; // Clear
          });
          print("Weather is misty or foggy");
        } else if (weatherId == 800) {
          setState(() {
            weatherEmoji = "☀️"; // Clear
          });
          print("Weather is clear");
        } else if (weatherId > 800) {
          setState(() {
            weatherEmoji = "☁️"; // Cloudy
          });
          print("Weather is cloudy");
        }
        setState(() {
          var temp = weatherData['main']['temp'];
          this.temp = temp.toString();
          this.cityName = weatherData['name'];
          this.weatherType = weatherData['weather'][0]['main'];
        });
        print("Weather Description: $weatherData");
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/sunset_image.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding:  EdgeInsets.only(top: 30.0),
            child: Stack(
              children: [
                Column(
                children: [
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => SearchCity(),
                            ));
                          },
                          icon: Image(
                            image: AssetImage("assets/search_location.png"),
                            height: height * 0.07,
                            width: width * 0.07,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              _determinePosition();
                            });
                          },
                          icon: Image(
                            image: AssetImage("assets/current_location.png"),
                            height: height * 0.07,
                            width: width * 0.07,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    cityName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    temp,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          weatherEmoji,
                          style: TextStyle(
                            fontSize: width * 0.22,
                          ),
                        ),
                        SizedBox(
                          width: width * 0.02,
                        ),
                        Text(
                          weatherType,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
                 if(isLoading)
                   Center(
                       child: CircularProgressIndicator(
                         color: Colors.blue,
                         strokeWidth: 5.0,
                       )
                   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
