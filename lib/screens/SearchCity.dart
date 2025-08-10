import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ScreenOne.dart';

class SearchCity extends StatefulWidget {
  const SearchCity({super.key});

  @override
  State<SearchCity> createState() => _SearchCityState();
}

class _SearchCityState extends State<SearchCity> {

  late TextEditingController _cityController;

  Future<void> getWeatherDataAsPerCityName(String cityName) async {
    print("Fetching weather details for $cityName");
    var apiKey = "0ddcf8e969046e9c2ffbb3670c6aa066";
    var url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'q': cityName,
      'appid': apiKey,
      'units': 'metric',
    });

    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      print("Weather data for $cityName: $jsonResponse");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ScreenOne(
          weatherData: jsonResponse,
        )),
            (Route<dynamic> route) => false, // This clears all previous routes
      );
    }
    else {
      print("Failed to fetch weather data for $cityName");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("City not found. Please try again.")),
      );
    }
    print("api complete");
  }

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;


    return Scaffold(
       body:  Center(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/secondScreenImage.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.08),
                      child: IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios,size: 20,color: Colors.white,)
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(top: height * 0.02),
                      child: TextField(
                        controller: _cityController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          labelStyle: TextStyle(color: Colors.white),
                          hintText: "Enter City Name",
                          hintStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(onPressed: (){
                        getWeatherDataAsPerCityName(_cityController.text);
                      }, child: Text(
                        "Search",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: width * 0.05,
                        ),
                      )),
                    )
                  ],
                ),
              ),
            ),
        )
    );
  }
}
