import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:yala_pay/database/city_dao.dart';
import 'package:yala_pay/database/country_dao.dart';

class CountryCityRepo {
  final CountryDao countryDao;
  final CityDao cityDao;

  CountryCityRepo({required this.countryDao, required this.cityDao});

  /// initialize countries & cities
  Future<void> initializeData() async {
    final existingCountries = await countryDao.getCountries();
    if (existingCountries.isEmpty) {
      try {
        print('Loading countries & cities...');
        final String data =
            await rootBundle.loadString('assets/data/countries.json');
        final Map<String, dynamic> countryCityMap = json.decode(data);

        for (var entry in countryCityMap.entries) {
          final countryName = entry.key;
          final cities = entry.value as List<dynamic>;
          // add country
          await countryDao.addCountry(countryName);
          // add country's cities
          for (var cityName in cities) {
            await cityDao.addCity(cityName as String, countryName);
          }
        }
        print('Successfully loaded countries & cities');
      } on Exception catch (e) {
        print('Error initializing countries & cities: $e');
      }
    }
  }

  /// get all countries
  Future<List<String>> getCountries() => countryDao.getCountries();

  /// get cities in a country
  Future<List<String>> getCitiesInCountry(String country) =>
      cityDao.getCitiesInCountry(country);
}
