import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    fetchWeatherData(city);
  }

  void fetchWeatherData(String city) async {
    try {
      final weather = await weatherApi.fetchCurrentWeather(city);
      setState(() {
        weatherData = weather;
      });
    } catch (e) {
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
            ? Center(
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

  WeatherDetails({required this.weatherData, required this.weatherImage});

  String formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return weatherData == null
        ? Container()
        : Card(
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
                    '${weatherData!['main']['temp']}°C',
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
                  Text(
                    'Humidity: ${weatherData!['main']['humidity']}%',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Wind: ${weatherData!['wind']['speed']} m/s, ${weatherData!['wind']['deg']}°',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Sunrise: ${formatTime(weatherData!['sys']['sunrise'])}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Sunset: ${formatTime(weatherData!['sys']['sunset'])}',
                    style: TextStyle(fontSize: 16),
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
