import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApi {
  final String apiKey = '6e59bf7aeed7fc155f4cd676f5d87302';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Fetch current weather data by city name
  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final url = Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  // Fetch forecast data by latitude and longitude
  Future<Map<String, dynamic>> fetchForecast(double lat, double lon) async {
    final url = Uri.parse(
        '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch forecast data');
    }
  }
}
