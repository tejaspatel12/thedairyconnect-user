import 'package:flutter/material.dart';
class StateList {
  final String state_id;
  final String state_name;
  final String country_id;
  final String state_status;


  StateList({
    @required this.state_id,
    @required this.state_name,
    @required this.country_id,
    @required this.state_status,
  });

  factory StateList.fromJson(Map<String, dynamic> json) {
    return StateList(
      state_id: json['state_id'],
      state_name: json['state_name'],
      country_id: json['country_id'],
      state_status: json['state_status'],
    );
  }
}
