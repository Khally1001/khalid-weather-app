import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main(List<String> args) {
  runApp(const MyWeatherApp());
}

class MyWeatherApp extends StatelessWidget {
  const MyWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String apiKey = 'd3944d556eb46075c0d8335918a64ee8';
  final TextEditingController cityController = TextEditingController();
  String error = '';
  dynamic weatherData;
  bool isLoading = false;
  IconData getWeatherIcon(String iconCode) {
    switch (iconCode.substring(0, 2)) {
      case '01':
        return Icons.wb_sunny;
      case '02':
      case '03':
      case '04':
        return Icons.cloud;
      case '09':
      case '10':
        return Icons.water_drop;
      case '11':
        return Icons.flash_on;
      case '13':
        return Icons.ac_unit;
      case '50':
        return Icons.foggy;

      default:
        return Icons.error;
    }
  }

  Future<void> fetchWeatherData() async {
    setState(() {
      error = '';
      weatherData = null;
    });
    if (cityController.text.isEmpty) {
      setState(() {
        error = 'Please enter a city name';
        isLoading = false;
      });
      return;
    }
    try {
      final city = cityController.text;
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          weatherData = data;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          error = 'City not found';
        });
      } else {
        setState(() {
          error = 'failed to reach api';
        });
      }
      {}
    } catch (e) {
      setState(() {
        error = 'failed to get data try again later';
      });
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather App')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  hintText: 'Type the city',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      isLoading = true;
                      fetchWeatherData();
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
                onSubmitted: (value) {
                  isLoading = true;
                  fetchWeatherData();
                },
              ),
              if (isLoading) SizedBox(height: 25),
              if (isLoading) const CircularProgressIndicator(),
              if (error.isNotEmpty)
                Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text(error, style: TextStyle(fontSize: 17))],
                    ),
                  ),
                ),
              if (weatherData != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(),

                      child: Column(
                        children: [
                          Text(
                            '${weatherData['name']},${weatherData['sys']['country']}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text('${weatherData['main']['feels_like']}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                getWeatherIcon(
                                  weatherData['weather'][0]['icon'],
                                ),
                                color:
                                    weatherData['weather'][0]['icon'] == '01d'
                                        ? Colors.orange
                                        : (weatherData['weather'][0]['icon'] ==
                                                '02' ||
                                            weatherData['weather'][0]['icon'] ==
                                                '03' ||
                                            weatherData['weather'][0]['icon'] ==
                                                '04')
                                        ? Colors.blue
                                        : Colors.grey,
                                size: 50,
                              ),
                              SizedBox(width: 20),
                              Text(
                                weatherData['weather'][0]['description'],
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Album {
  final coord;
  final weather;
  final base;
  final main;
  final visibility;
  final wind;
  final clouds;
  final sys;
  final timezone;
  final id;
  final cod;
  final name;
  Album({
    this.coord,
    this.weather,
    this.base,
    this.main,
    this.visibility,
    this.wind,
    this.clouds,
    this.sys,
    this.timezone,
    this.id,
    this.cod,
    this.name,
  });
  factory Album.fromjson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'coord': double coord,
        'weather': String weather,
        'base': String base,
        'main': String main,
        'visibility': int visibility,
        'wind': String wind,
        'clouds': String clouds,
        'sys': String sys,
        'timezone': String timezone,
        'id': int id,
        'cod': String cod,
        'name': String name,
      } =>
        Album(
          coord: coord,
          weather: weather,
          base: base,
          main: main,
          visibility: visibility,
          wind: wind,
          clouds: clouds,
          sys: sys,
          timezone: timezone,
          id: id,
          cod: cod,
          name: name,
        ),
      _ => throw const FormatException('Failed to load album'),
    };
  }
}
