import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'organization.g.dart';

@HiveType(typeId: 8)
class Organization {
  @HiveField(0)
  String? name;
  @HiveField(1)
  String? countryId;
  @HiveField(2)
  String? organizationId;
  @HiveField(3)
  String? email;
  @HiveField(4)
  String? countryName;
  @HiveField(5)
  String? created;

  Organization(
      {required this.name,
      required this.countryId,
      required this.email,
      required this.created,
      required this.countryName,
      required this.organizationId});

  Organization.fromJson(Map data) {
    this.name = data['name'];
    this.countryId = data['countryId'];
    this.organizationId = data['organizationId'];
    this.email = data['email'];
    this.countryName = data['countryName'];
    this.organizationId = data['organizationId'];
    this.created = data['created'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': name,
      'created': created,
      'countryId': countryId,
      'organizationId': organizationId,
      'email': email,
      'countryName': countryName,
      'organizationId': organizationId,
    };
    return map;
  }
}