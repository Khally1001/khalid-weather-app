import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:weather_icons/weather_icons.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
      ),
      home: WeatherApp(),
    ),
  );
}

class WeatherData {
  var cloud;
  var icon;
  var temperature;
  var location;
  var name;
  var windSpeed;
  var pressure;
  var humidity;
  var minTemp;
  var lat;
  var lon;
  WeatherData({
    required this.cloud,
    required this.icon,
    required this.temperature,
    required this.location,
    required this.name,
    required this.windSpeed,
    required this.pressure,
    required this.humidity,
    required this.minTemp,
    required this.lat,
    required this.lon,
  });
  factory WeatherData.fromjson(Map<String, dynamic> json) {
    return WeatherData(
      cloud: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temperature: json['main']['temp'],
      location: json['sys']['country'],
      name: json['name'],
      windSpeed: json['wind']['speed'],
      pressure: json['main']['pressure'],
      humidity: json['main']['humidity'],
      minTemp: json['main']['temp_min'],
      lat: json['coord']['lat'],
      lon: json['coord']['lon'],
    );
  }
}

class DailyForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final double avgTemp;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.avgTemp,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json, int index) {
    // we pass the index to pick the right element from each array
    return DailyForecast(
      date: json['daily']['time'][index],
      maxTemp: (json['daily']['temperature_2m_max'][index]).toDouble(),
      minTemp: (json['daily']['temperature_2m_min'][index]).toDouble(),
      avgTemp:
          ((json['daily']['temperature_2m_max'][index] +
                      json['daily']['temperature_2m_min'][index]) /
                  2)
              .toDouble(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  late Future<WeatherData> futureWeather;
  late Future<List<DailyForecast>> forcast;
  @override
  void initState() {
    super.initState();
    // start with a default city, fetch both weather and forecast once:
    futureWeather = fetchData();
    futureWeather.then((weather) {
      setState(() {
        forcast = fetchDailyTemperatire(weather.lat, weather.lon);
      });
    });
  }

  final apiKey = 'd3944d556eb46075c0d8335918a64ee8';
  String city = 'London';
  String error = '';
  Future<WeatherData> fetchData() async {
    final url = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
      ),
    );
    if (url.statusCode == 200) {
      return WeatherData.fromjson(jsonDecode(url.body));
    } else {
      throw Exception('Error: ${url.statusCode}');
    }
  }

  Future<List<DailyForecast>> fetchDailyTemperatire(
    double lat,
    double lon,
  ) async {
    var url = await http.get(
      Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min&forecast_days=3&timezone=auto',
      ),
    );
    if (url.statusCode == 200) {
      final data = jsonDecode(url.body);
      final int daysCount = data['daily']['time'].length;
      return List.generate(daysCount, (i) => DailyForecast.fromJson(data, i));
    } else {
      throw Exception('Could not fetch data');
    }
  }

  TextEditingController cityName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather App')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Srawana"),
              accountEmail: Text("example@email.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage(
                  'assets/images/81fdb4ad5a1008865197b7132a5f565c.jpg',
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.map_outlined),
              title: Text(
                'Map',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text(
                'Saved Location',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.calendar_month),
              title: Text(
                'Calendar',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'January 2022',
                                      style: TextStyle(
                                        color: Color(0XFF18233E),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Thursday, Jan 4,2022',
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 70),
                                Expanded(
                                  child: TextField(
                                    controller: cityName,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      hintText: 'Enter city name',
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onSubmitted: (value) async {
                                      city = cityName.text; // update city
                                      final weather =
                                          await fetchData(); // wait for weather data
                                      setState(() {
                                        futureWeather = Future.value(
                                          weather,
                                        ); // update future
                                        forcast = fetchDailyTemperatire(
                                          weather.lat,
                                          weather.lon,
                                        );
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final weather = await fetchData();
                                    setState(() {
                                      futureWeather = Future.value(weather);
                                      forcast = fetchDailyTemperatire(
                                        weather.lat,
                                        weather.lon,
                                      );
                                    });
                                  },
                                  icon: Icon(Icons.search_rounded),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.notifications),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.person),
                                ),
                              ],
                            ),
                            SizedBox(height: 35),
                            Divider(thickness: 2),
                            ListTile(
                              leading: Text(
                                'Today overview',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0XFF18233E),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'More detail',
                                    style: TextStyle(color: Color(0xFF6D86BD)),
                                  ),
                                  Icon(
                                    Icons.more_horiz,
                                    color: Color(0xFF6D86BD),
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder(
                              future: futureWeather,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      snapshot.error.toString(),
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  var weather = snapshot.data;
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(width: 20),
                                          SizedBox(
                                            width: 300,
                                            height: 100,
                                            child: Center(
                                              child: Card(
                                                elevation: 0,
                                                color: Colors.grey.shade100,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        WeatherIcons
                                                            .wind_beaufort_0,
                                                        color: Color(
                                                          0XFF6D86BD,
                                                        ),
                                                      ),
                                                      SizedBox(width: 15),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 15,
                                                            ),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              'Wind Speed',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade600,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              '${weather?.windSpeed}km/h',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 50),
                                          SizedBox(
                                            width: 300,
                                            height: 100,
                                            child: Center(
                                              child: Card(
                                                elevation: 0,
                                                color: Colors.grey.shade100,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        WeatherIcons.barometer,
                                                        color: Color(
                                                          0XFF6D86BD,
                                                        ),
                                                      ),
                                                      SizedBox(width: 15),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 15,
                                                            ),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              'Pressure',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade600,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              '${weather?.pressure} hpa',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 20),
                                          SizedBox(
                                            width: 300,
                                            height: 100,
                                            child: Center(
                                              child: Card(
                                                elevation: 0,
                                                color: Colors.grey.shade100,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        WeatherIcons.humidity,
                                                        color: Color(
                                                          0XFF6D86BD,
                                                        ),
                                                      ),
                                                      SizedBox(width: 15),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 15,
                                                            ),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              'Humidity',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade600,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              '${weather?.humidity}%',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 50),
                                          SizedBox(
                                            width: 300,
                                            height: 100,
                                            child: Center(
                                              child: Card(
                                                elevation: 0,
                                                color: Colors.grey.shade100,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        WeatherIcons
                                                            .thermometer_internal,
                                                        color: Color(
                                                          0XFF6D86BD,
                                                        ),
                                                      ),
                                                      SizedBox(width: 15),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 15,
                                                            ),
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              'Min Temp',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade600,
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              '${weather?.minTemp} C',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                                return SizedBox();
                              },
                            ),
                            FutureBuilder<List<DailyForecast>>(
                              future: forcast,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Something went wrong: ${snapshot.error}',
                                  );
                                } else if (snapshot.hasData) {
                                  final threeDaysWeather =
                                      snapshot.data!; // safe to use ! here
                                  return SizedBox(
                                    height: 250,
                                    child: SfCartesianChart(
                                      primaryXAxis: CategoryAxis(),
                                      title: ChartTitle(
                                        text: '3-Day Average Temperature',
                                      ),
                                      tooltipBehavior: TooltipBehavior(
                                        enable: true,
                                      ),
                                      series: <
                                        CartesianSeries<DailyForecast, String>
                                      >[
                                        LineSeries<DailyForecast, String>(
                                          name: 'Avg Temp (°C)',
                                          dataSource: threeDaysWeather,
                                          xValueMapper:
                                              (DailyForecast forecast, _) =>
                                                  forecast.date,
                                          yValueMapper:
                                              (DailyForecast forecast, _) =>
                                                  forecast.avgTemp,
                                          markerSettings: MarkerSettings(
                                            isVisible: true,
                                          ),
                                          dataLabelSettings: DataLabelSettings(
                                            isVisible: true,
                                          ),
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0XFF223C57), Color(0XFF173A7E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),

                      child: FutureBuilder(
                        future: futureWeather,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                snapshot.error.toString(),
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          if (snapshot.hasData) {
                            var rightWeather = snapshot.data;
                            return Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${rightWeather?.name}',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${rightWeather?.location}',
                                    style: TextStyle(
                                      color: Colors.grey.shade300,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          'https://openweathermap.org/img/wn/${rightWeather?.icon}@2x.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${rightWeather?.temperature}C',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w200,
                                          fontSize: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${rightWeather?.cloud}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  SizedBox(height: 10),
                                ],
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
