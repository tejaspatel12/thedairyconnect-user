import 'package:flutter/material.dart';
class CityList {
  final String city_id;
  final String city_name;
  final String state_id;
  final String city_status;


  CityList({
    @required this.city_id,
    @required this.city_name,
    @required this.state_id,
    @required this.city_status,
  });

  factory CityList.fromJson(Map<String, dynamic> json) {
    return CityList(
      city_id: json['city_id'],
      city_name: json['city_name'],
      state_id: json['state_id'],
      city_status: json['city_status'],
    );
  }
}
