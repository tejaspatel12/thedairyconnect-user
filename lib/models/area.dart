import 'package:flutter/material.dart';
class AreaList {
  final String area_id;
  final String city_id;
  final String area_name;
  final String area_status;


  AreaList({
    @required this.area_id,
    @required this.city_id,
    @required this.area_name,
    @required this.area_status,
  });

  factory AreaList.fromJson(Map<String, dynamic> json) {
    return AreaList(
      area_id: json['area_id'],
      city_id: json['city_id'],
      area_name: json['area_name'],
      area_status: json['area_status'],
    );
  }
}
