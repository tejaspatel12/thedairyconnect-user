import 'package:flutter/material.dart';
class InvoiceList {
  final String di_id;
  final String user_id;
  final String deliveryboy_id;
  final String di_title;
  final String di_fdate;
  final String di_edate;


  InvoiceList({
    @required this.di_id,
    @required this.user_id,
    @required this.deliveryboy_id,
    @required this.di_title,
    @required this.di_fdate,
    @required this.di_edate,
  });

  factory InvoiceList.fromJson(Map<String, dynamic> json) {
    return InvoiceList(
      di_id: json['di_id'],
      user_id: json['user_id'],
      deliveryboy_id: json['deliveryboy_id'],
      di_title: json['di_title'],
      di_fdate: json['di_fdate'],
      di_edate: json['di_edate'],
    );
  }
}
