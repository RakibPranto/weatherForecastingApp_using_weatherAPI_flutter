// ignore_for_file: unnecessary_string_interpolations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:weather_icons/weather_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;
  var lat;
  var lon;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;
  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
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

    position = await Geolocator.getCurrentPosition();
    lat = position!.latitude;
    lon = position!.longitude;
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherApi =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=b510656fee5e075dcf3e676d9f978fa2';
    String forecastApi =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=b510656fee5e075dcf3e676d9f978fa2';
    var weatherResponse = await http.get(Uri.parse(weatherApi));
    var forecastResponse = await http.get(Uri.parse(forecastApi));
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    });
  }

  @override
  void initState() {
    _determinePosition(); // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: weatherMap == null
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/day.jpg"),
                        fit: BoxFit.cover)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 25,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${weatherMap!["name"]}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  "${Jiffy(DateTime.now()).format("MMM do yy, h:mm")}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 25,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 120,
                        ),
                        Text(
                          "${(weatherMap!["main"]["temp"] - 273).toStringAsFixed(0)}°C",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 80,
                          ),
                        ),
                        Text(
                          "${weatherMap!["weather"][0]["main"]}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 80,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: forecastMap!.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      forecastMap!["list"][index]["weather"][0]
                                                  ["description"] ==
                                              "Haze"
                                          ? WeatherIcons.day_haze
                                          : forecastMap!["list"][index]
                                                          ["weather"][0]
                                                      ["description"] ==
                                                  "broken clouds"
                                              ? WeatherIcons.cloudy_gusts
                                              : forecastMap!["list"][index]
                                                              ["weather"][0]
                                                          ["description"] ==
                                                      "light rain"
                                                  ? WeatherIcons.day_rain
                                                  : forecastMap!["list"][index]
                                                                  ["weather"][0]
                                                              ["description"] ==
                                                          "overcast clouds"
                                                      ? WeatherIcons
                                                          .day_cloudy_windy
                                                      : WeatherIcons.cloud,
                                      color: Colors.yellow,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE")}-",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      " ${forecastMap!["list"][index]["weather"][0]["description"]}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      " ${(forecastMap!["list"][index]["main"]["temp"] - 273).toStringAsFixed(0)}°",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 20,
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: forecastMap!.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("h:mm")}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Icon(
                                      forecastMap!["list"][index]["weather"][0]
                                                  ["description"] ==
                                              "Haze"
                                          ? WeatherIcons.day_haze
                                          : forecastMap!["list"][index]
                                                          ["weather"][0]
                                                      ["description"] ==
                                                  "broken clouds"
                                              ? WeatherIcons.cloudy_gusts
                                              : forecastMap!["list"][index]
                                                              ["weather"][0]
                                                          ["description"] ==
                                                      "light rain"
                                                  ? WeatherIcons.day_rain
                                                  : forecastMap!["list"][index]
                                                                  ["weather"][0]
                                                              ["description"] ==
                                                          "overcast clouds"
                                                      ? WeatherIcons
                                                          .day_cloudy_windy
                                                      : WeatherIcons.cloud,
                                      color: Colors.yellow,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      " ${forecastMap!["list"][index]["weather"][0]["description"]}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                width: 5,
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Weather Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Feels Like\n${(weatherMap!["main"]["feels_like"] - 273).toStringAsFixed(0)}°C",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Humidity\n${weatherMap!["main"]["humidity"]}%",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Wind Speed\n${weatherMap!["wind"]["speed"]}km/h",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Humidity\n${weatherMap!["main"]["humidity"]}%",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Visibility\n${weatherMap!["visibility"] / 1000}km",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Air Pressure\n${weatherMap!["main"]["pressure"]}hPa",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 50,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
