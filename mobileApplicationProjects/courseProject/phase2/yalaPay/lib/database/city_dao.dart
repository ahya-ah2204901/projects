import 'package:floor/floor.dart';

@dao
abstract class CityDao {
  /// adding a city to the db (used instead of @insert because the file has duplicates)
  @Query(
      'INSERT OR IGNORE INTO cities (cityName, countryName) VALUES (:cityName, :countryName)')
  Future<void> addCity(String cityName, String countryName);

  /// get cities in a country
  @Query('SELECT cityName FROM cities WHERE countryName = :countryName')
  Future<List<String>> getCitiesInCountry(String countryName);
}
