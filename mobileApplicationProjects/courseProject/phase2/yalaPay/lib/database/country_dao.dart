import 'package:floor/floor.dart';

@dao
abstract class CountryDao {
  /// add a country to db (used instead of @insert because the file has duplicates)
  @Query('INSERT OR IGNORE INTO countries (countryName) VALUES (:countryName)')
  Future<void> addCountry(String countryName);

  /// get all countries
  @Query('SELECT countryName FROM countries')
  Future<List<String>> getCountries();
}
