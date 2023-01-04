import 'package:geo_monitor/library/data/position.dart';

class City {
  String? name, countryId, countryName, provinceName, cityId, created;
  Position? position;

  City(
      {required this.name,
      required this.countryId,
      required this.provinceName,
      required this.countryName,
      required this.position,
      required this.created});

  City.fromJson(Map data) {
    name = data['name'];
    countryId = data['countryId'];
    countryName = data['countryName'];
    provinceName = data['provinceName'];
    countryName = data['countryName'];
    created = data['created'];
    cityId = data['cityId'];
    if (data['position'] != null) {
      position = Position.fromJson( data['position']);
    }

  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'countryId': countryId,
      'countryName': countryName,
      'provinceName': provinceName,
      'cityId': cityId,
      'created': created,
      'position': position == null? null : position!.toJson(),
    };
    return map;
  }
}
