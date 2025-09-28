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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('ATMOS', style: TextStyle(fontFamily: 'Roboto')),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                "Atomos",
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              accountEmail: Text("example@email.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.lightBlue,
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
                                SizedBox(width: width * 0.0512),
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
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: width * 0.08,
                                    maxHeight: height * 0.08,
                                  ),
                                  child: FittedBox(
                                    child: IconButton(
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
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: width * 0.08,
                                    maxHeight: height * 0.08,
                                  ),
                                  child: FittedBox(
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.notifications),
                                    ),
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: width * 0.08,
                                    maxHeight: height * 0.08,
                                  ),
                                  child: FittedBox(
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.person),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.0455),
                            Divider(thickness: 2),
                            ListTile(
                              title: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: width * 0.7,
                                ),
                                child: Text(
                                  'Today overview',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0XFF18233E),
                                  ),
                                ),
                              ),
                              trailing: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: width * 0.3,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'More detail',
                                      style: TextStyle(
                                        color: Color(0xFF6D86BD),
                                      ),
                                    ),
                                    Icon(
                                      Icons.more_horiz,
                                      color: Color(0xFF6D86BD),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            FutureBuilder(
                              future: futureWeather,
                              builder: (context, snapshot) {
                                // Get screen size once at the top
                                double screenWidth =
                                    MediaQuery.of(context).size.width;
                                double screenHeight =
                                    MediaQuery.of(context).size.height;

                                // Pick breakpoint where layout switches
                                bool isWideScreen = screenWidth > 600;

                                // Card width and spacing change depending on screen width
                                double cardWidth =
                                    (isWideScreen
                                            ? screenWidth * 0.2196
                                            : screenWidth * 0.9)
                                        .toDouble();
                                double cardSpacing =
                                    (isWideScreen ? screenWidth * 0.0366 : 0)
                                        .toDouble();
                                double sideSpacing =
                                    (isWideScreen ? screenWidth * 0.0146 : 0)
                                        .toDouble();

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text(
                                        'Something went wrong',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  var weather = snapshot.data;
                                  return Column(
                                    children: [
                                      Wrap(
                                        direction: Axis.horizontal,
                                        runSpacing: 8,
                                        children: [
                                          SizedBox(width: sideSpacing),
                                          SizedBox(
                                            width: cardWidth,
                                            height:
                                                (screenHeight * 0.13)
                                                    .toDouble(),
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
                                                      ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                              maxWidth:
                                                                  (screenWidth *
                                                                          0.1)
                                                                      .toDouble(),
                                                            ),
                                                        child: const Icon(
                                                          WeatherIcons
                                                              .wind_beaufort_0,
                                                          color: Color(
                                                            0XFF6D86BD,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            (screenWidth *
                                                                    0.011)
                                                                .toDouble(),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 15,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                maxWidth:
                                                                    (screenWidth *
                                                                            0.3)
                                                                        .toDouble(),
                                                              ),
                                                              child: const Text(
                                                                'Wind Speed',
                                                                softWrap: true,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  color: Color(
                                                                    0xFF888888,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                maxWidth:
                                                                    (screenWidth *
                                                                            0.3)
                                                                        .toDouble(),
                                                              ),
                                                              child: Text(
                                                                '${weather?.windSpeed}km/h',
                                                                softWrap: true,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
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
                                          SizedBox(width: cardSpacing),
                                          // second card …
                                          SizedBox(
                                            width: cardWidth,
                                            height:
                                                (screenHeight * 0.13)
                                                    .toDouble(),
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
                                                      ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                              maxWidth:
                                                                  (screenWidth *
                                                                          0.1)
                                                                      .toDouble(),
                                                            ),
                                                        child: const Icon(
                                                          WeatherIcons
                                                              .barometer,
                                                          color: Color(
                                                            0XFF6D86BD,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            (screenWidth *
                                                                    0.011)
                                                                .toDouble(),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 15,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                maxWidth:
                                                                    (screenWidth *
                                                                            0.3)
                                                                        .toDouble(),
                                                              ),
                                                              child: const Text(
                                                                'Pressure',
                                                                softWrap: true,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  fontSize: 15,
                                                                  color: Color(
                                                                    0xFF888888,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                maxWidth:
                                                                    (screenWidth *
                                                                            0.3)
                                                                        .toDouble(),
                                                              ),
                                                              child: Text(
                                                                '${weather?.pressure} hpa',
                                                                softWrap: true,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
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
                                      // second row
                                      Wrap(
                                        direction: Axis.horizontal,
                                        runSpacing: 8,
                                        children: [
                                          SizedBox(width: sideSpacing),
                                          SizedBox(
                                            width: cardWidth,
                                            height:
                                                (screenHeight * 0.13)
                                                    .toDouble(),
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
                                                      const Icon(
                                                        WeatherIcons.humidity,
                                                        color: Color(
                                                          0XFF6D86BD,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            (screenWidth *
                                                                    0.011)
                                                                .toDouble(),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 15,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Humidity',
                                                              softWrap: true,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 15,
                                                                color: Color(
                                                                  0xFF888888,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              '${weather?.humidity}%',
                                                              style: const TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 15,
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
                                          SizedBox(width: cardSpacing),
                                          SizedBox(
                                            width: cardWidth,
                                            height:
                                                (screenHeight * 0.13)
                                                    .toDouble(),
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
                                                      const Icon(
                                                        WeatherIcons
                                                            .thermometer_internal,
                                                        color: Color(
                                                          0XFF6D86BD,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            (screenWidth *
                                                                    0.011)
                                                                .toDouble(),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 15,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Min Temp',
                                                              softWrap: true,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 15,
                                                                color: Color(
                                                                  0xFF888888,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              '${weather?.minTemp} C',
                                                              style: const TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 15,
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
                                return const SizedBox();
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
                                    height: height * 0.3255,
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
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: width * 0.1,
                                    ),
                                    child: FittedBox(
                                      child: Text(
                                        '${rightWeather?.name}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: width * 0.1,
                                    ),
                                    child: Text(
                                      '${rightWeather?.location}',
                                      style: TextStyle(
                                        color: Colors.grey.shade300,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: width * 0.1,
                                    ),
                                    child: Container(
                                      width: width * 0.037,
                                      height: height * 0.065,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            'https://openweathermap.org/img/wn/${rightWeather?.icon}@2x.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: width * 0.1,
                                        ),
                                        child: Text(
                                          '${rightWeather?.temperature}C',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w200,
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: width * 0.1,
                                        ),
                                        child: Text(
                                          '${rightWeather?.cloud}',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  SizedBox(height: height * 0.013),
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
