import 'package:geo_monitor/library/data/position.dart';
import 'package:hive/hive.dart';

part 'city.g.dart';

@HiveType(typeId: 7)
class City {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? countryId;
  @HiveField(2)
  String? countryName;
  @HiveField(3)
  String? provinceName;
  @HiveField(4)
  String? cityId;
  @HiveField(5)
  String? created;
  @HiveField(6)
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
