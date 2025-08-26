import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app_youtube/screens/home_screen.dart';

import 'bloc/weather_bloc_bloc.dart';
import 'bloc/weather_bloc_event.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WeatherBlocBloc>(
      create: (context) => WeatherBlocBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            future: _determinePosition(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snap.hasError) {
                // في حالة وجود خطأ في جلب الموقع
                return Scaffold(
                  body: Center(
                    child: Text(
                      'Error: ${snap.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else if (snap.hasData) {
                // إذا تم جلب الموقع بنجاح
                BlocProvider.of<WeatherBlocBloc>(context).add(
                  FetchWeather(snap.data as Position),
                );
                return const HomeScreen();
              } else {
                return const Scaffold(
                  body: Center(
                    child: Text('No location data available.'),
                  ),
                );
              }
            }),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

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

  return await Geolocator.getCurrentPosition();
}
