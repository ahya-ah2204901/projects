import 'package:floor/floor.dart';

@Entity(tableName: "countries")
class Country {
  @PrimaryKey()
  final String countryName;

  Country({required this.countryName});
}
