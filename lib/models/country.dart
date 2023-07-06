import 'package:flutter/material.dart';
class CountryList {
  final String country_id;
  final String country_code;
  final String country_name;
  final String country_status;


  CountryList({
    @required this.country_id,
    @required this.country_code,
    @required this.country_name,
    @required this.country_status,
  });

  factory CountryList.fromJson(Map<String, dynamic> json) {
    return CountryList(
      country_id: json['country_id'],
      country_code: json['country_code'],
      country_name: json['country_name'],
      country_status: json['country_status'],
    );
  }
}
