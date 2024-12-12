import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/weather_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherApi weatherApi = WeatherApi();
  Map<String, dynamic>? weatherData;
  String city = 'Atlanta';
  bool showFahrenheit = false; // Toggle for Celsius/Fahrenheit
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchWeatherData(city);
  }

  void fetchWeatherData(String city) async {
    try {
      setState(() {
        errorMessage = null; // Clear any previous errors
      });
      final weather = await weatherApi.fetchCurrentWeather(city);
      setState(() {
        weatherData = weather;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Invalid city or unable to fetch weather data.';
      });
      print('Error fetching weather data: $e');
    }
  }

  String getWeatherImage(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
        return 'web/assets/images/cloudy.png';
      case 'rain':
        return 'web/assets/images/rainy.png';
      case 'clear':
        return 'web/assets/images/sunny.png';
      default:
        return 'web/assets/images/background1.jpg'; // Fallback
    }
  }

  double convertToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  String formatTime(int timestamp) {
    return DateFormat('hh:mm a').format(
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weatherly'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('web/assets/images/background1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: weatherData == null
            ? errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      onSubmitted: (value) {
                        setState(() {
                          city = value;
                          weatherData = null;
                        });
                        fetchWeatherData(city);
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter city name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    WeatherDetails(
                      weatherData: weatherData,
                      weatherImage: getWeatherImage(
                          weatherData!['weather'][0]['main']),
                      showFahrenheit: showFahrenheit,
                      toggleTemperature: () {
                        setState(() {
                          showFahrenheit = !showFahrenheit;
                        });
                      },
                      formatTime: formatTime,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RadarMapScreen()),
                        );
                      },
                      child: Text('View Radar Map'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class WeatherDetails extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String weatherImage;
  final bool showFahrenheit;
  final VoidCallback toggleTemperature;
  final String Function(int) formatTime;

  WeatherDetails({
    required this.weatherData,
    required this.weatherImage,
    required this.showFahrenheit,
    required this.toggleTemperature,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) return Container();

    final tempCelsius = weatherData!['main']['temp'];
    final temp = showFahrenheit
        ? (tempCelsius * 9 / 5) + 32
        : tempCelsius; // Convert to Fahrenheit if toggled

    final humidity = weatherData!['main']['humidity'];
    final windSpeed = weatherData!['wind']['speed'];
    final windDirection = weatherData!['wind']['deg'];
    final sunrise = formatTime(weatherData!['sys']['sunrise']);
    final sunset = formatTime(weatherData!['sys']['sunset']);

    return Card(
      color: Colors.white.withOpacity(0.8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${weatherData!['name']}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.asset(
              weatherImage,
              fit: BoxFit.cover,
              height: 100,
              width: 100,
            ),
            Text(
              '${temp.toStringAsFixed(1)}°${showFahrenheit ? 'F' : 'C'}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            Text(
              '${weatherData!['weather'][0]['description']}',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 10),
            Text('Humidity: $humidity%'),
            Text('Wind: $windSpeed m/s, $windDirection°'),
            Text('Sunrise: $sunrise'),
            Text('Sunset: $sunset'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: toggleTemperature,
              child: Text(
                'Switch to ${showFahrenheit ? 'Celsius' : 'Fahrenheit'}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadarMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Radar Map')),
      body: Center(
        child: Image.asset(
          'web/assets/images/radar_map.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
