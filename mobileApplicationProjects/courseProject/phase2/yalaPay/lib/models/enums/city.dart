import 'package:floor/floor.dart';

import 'country.dart';

@Entity(tableName: "cities", foreignKeys: [
  ForeignKey(
    childColumns: ["countryName"],
    parentColumns: ["countryName"],
    entity: Country,
  )
], primaryKeys: [
  'cityName',
  'countryName'
])
class City {
  final String cityName;
  final String countryName; // fk to the country

  City({required this.cityName, required this.countryName});
}
