import 'package:feep_competition2021/models/dailyWeather.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';

import '../main.dart';
import '../models/weather.dart';

class WeatherProvider with ChangeNotifier {
  String apiKey = config['OpenWeatherApiKey'];
  Weather weather = Weather();
  DailyWeather currentWeather = DailyWeather();
  List<DailyWeather> hourlyWeather = [];
  List<DailyWeather> hourly24Weather = [];
  List<DailyWeather> fiveDayWeather = [];
  List<DailyWeather> sevenDayWeather = [];
  bool loading;
  bool isRequestError = false;
  bool isLocationError = false;

  getWeatherData() async {
    loading = true;
    isRequestError = false;
    isLocationError = false;
    await Location().requestService().then((value) async {
      if (value) {
        final locData = await Location().getLocation();
        var latitude = locData.latitude;
        var longitude = locData.longitude;
        var url =
            'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';
        var dailyUrl =
            'https://api.openweathermap.org/data/2.5/onecall?lat=$latitude&lon=$longitude&units=metric&exclude=minutely,current&appid=$apiKey';
        try {
          final response = await http.get(url);
          final extractedData =
              json.decode(response.body) as Map<String, dynamic>;
          weather = Weather.fromJson(extractedData);
        } catch (error) {
          loading = false;
          this.isRequestError = true;
          notifyListeners();
        }
        try {
          final response = await http.get(dailyUrl);
          final dailyData = json.decode(response.body) as Map<String, dynamic>;
          currentWeather = DailyWeather.fromJson(dailyData);
          var tempHourly = [];
          var temp24Hour = [];
          var tempSevenDay = [];
          List items = dailyData['daily'];
          List itemsHourly = dailyData['hourly'];
          tempHourly = itemsHourly
              .map((item) => DailyWeather.fromHourlyJson(item))
              .toList()
              .skip(1)
              .take(3)
              .toList();
          temp24Hour = itemsHourly
              .map((item) => DailyWeather.fromHourlyJson(item))
              .toList()
              .skip(1)
              .take(24)
              .toList();
          tempSevenDay = items
              .map((item) => DailyWeather.fromDailyJson(item))
              .toList()
              .skip(1)
              .take(7)
              .toList();
          hourlyWeather = tempHourly;
          hourly24Weather = temp24Hour;
          sevenDayWeather = tempSevenDay;
          loading = false;
          notifyListeners();
        } catch (error) {
          loading = false;
          this.isRequestError = true;
          notifyListeners();
          throw error;
        }
      } else {
        loading = false;
        isLocationError = true;
        notifyListeners();
      }
    });
  }

  searchWeatherData({String location}) async {
    loading = true;
    isRequestError = false;
    isLocationError = false;

    var url =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&units=metric&appid=$apiKey';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      weather = Weather.fromJson(extractedData);
    } catch (error) {
      loading = false;
      this.isRequestError = true;
      notifyListeners();
      throw error;
    }
    var latitude = weather.lat;
    var longitude = weather.long;
    print(latitude);
    print(longitude);
    var dailyUrl =
        'https://api.openweathermap.org/data/2.5/onecall?lat=$latitude&lon=$longitude&units=metric&exclude=minutely,current&appid=$apiKey';
    try {
      final response = await http.get(dailyUrl);
      final dailyData = json.decode(response.body) as Map<String, dynamic>;
      print(dailyUrl);
      currentWeather = DailyWeather.fromJson(dailyData);
      var tempHourly = [];
      var temp24Hour = [];
      var tempSevenDay = [];
      List items = dailyData['daily'];
      List itemsHourly = dailyData['hourly'];
      tempHourly = itemsHourly
          .map((item) => DailyWeather.fromHourlyJson(item))
          .toList()
          .skip(1)
          .take(3)
          .toList();
      temp24Hour = itemsHourly
          .map((item) => DailyWeather.fromHourlyJson(item))
          .toList()
          .skip(1)
          .take(24)
          .toList();
      tempSevenDay = items
          .map((item) => DailyWeather.fromDailyJson(item))
          .toList()
          .skip(1)
          .take(7)
          .toList();
      hourlyWeather = tempHourly;
      hourly24Weather = temp24Hour;
      sevenDayWeather = tempSevenDay;
      loading = false;
      notifyListeners();
    } catch (error) {
      loading = false;
      this.isRequestError = true;
      notifyListeners();
      throw error;
    }
  }
}
