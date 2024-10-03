import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherWidget extends StatefulWidget {
  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final List<String> cities = ["Chernihiv"];
  Map<String, Map<String, String>> weatherData = {
    "Chernihiv": {"temperature": "", "condition": "", "iconUrl": "", "temperature_feel_like": "", "wind.speed": ""},
  };
  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    for (String city in cities) {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=f7c04a7ff33f25f5e03fdea16579a3bf&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weatherData[city] = {
            "temperature": "${data['main']['temp']}°C",
            "temperature_feel_like": "${data['main']['feels_like']}°C",
            "condition": data['weather'][0]['description'],
            "wind.speed": "${data['wind']['speed']} м/с",
            "iconUrl": "http://openweathermap.org/img/w/${data['weather'][0]['icon']}.png",
          };
        });
      } else {
        throw Exception('Не вдалося отримати погоду для $city');
      }
    }
  }

  void addCity() {
    String newCity = cityController.text;
    if (newCity.isNotEmpty) {
      if (!cities.contains(newCity)) {
        setState(() {
          cities.add(newCity);
          weatherData[newCity] = {"temperature": "", "condition": "", "iconUrl": "", "temperature_feel_like": "", "wind.speed": ""};
        });
        fetchWeather();
        cityController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Місто вже існує в списку')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Погода в місті'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: 'Додати місто',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addCity,
                  child: Text('Додати'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                String city = cities[index];
                return Card(
                  child: ListTile(
                    leading: weatherData[city]!['iconUrl']!.isNotEmpty
                        ? Image.network(weatherData[city]!['iconUrl']!, width: 50, height: 50)
                        : SizedBox(width: 50, height: 50),
                    title: Text(city),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Температура: ${weatherData[city]!['temperature']}'),
                        Text('Відчувається як: ${weatherData[city]!['temperature_feel_like']}'),
                        Text('Стан: ${weatherData[city]!['condition']}'),
                        Text('Швидкість вітру: ${weatherData[city]!['wind.speed']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WeatherWidget(),
  ));
}