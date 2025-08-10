import 'package:flutter/material.dart';
import 'package:weather_app/screens/ClimateHomeScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ClimateHomeScreen(),
    );
  }
}
