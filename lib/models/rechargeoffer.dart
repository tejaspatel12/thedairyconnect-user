
import 'package:flutter/material.dart';
class RechargeOfferList {
  final String ro_id;
  final String ro_title;
  final String ro_des;
  final String ro_amt;
  final String ro_get_amt;
  final String ro_status;


  RechargeOfferList({
    @required this.ro_id,
    @required this.ro_title,
    @required this.ro_des,
    @required this.ro_amt,
    @required this.ro_get_amt,
    @required this.ro_status,
  });

  factory RechargeOfferList.fromJson(Map<String, dynamic> json) {
    return RechargeOfferList(
      ro_id: json['ro_id'],
      ro_title: json['ro_title'],
      ro_des: json['ro_des'],
      ro_amt: json['ro_amt'],
      ro_get_amt: json['ro_get_amt'],
      ro_status: json['ro_status'],
    );
  }
}
