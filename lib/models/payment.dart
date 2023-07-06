import 'package:flutter/material.dart';
class PaymentList {
  final String payment_id;
  final String user_id;
  final String razorpay_payment_id;
  final String payment_amt;
  final String payment_type;
  final String payment_status;
  final String payment_time;


  PaymentList({
    @required this.payment_id,
    @required this.user_id,
    @required this.razorpay_payment_id,
    @required this.payment_amt,
    @required this.payment_type,
    @required this.payment_status,
    @required this.payment_time,
  });

  factory PaymentList.fromJson(Map<String, dynamic> json) {
    return PaymentList(
      payment_id: json['payment_id'],
      user_id: json['user_id'],
      razorpay_payment_id: json['razorpay_payment_id'],
      payment_amt: json['payment_amt'],
      payment_type: json['payment_type'],
      payment_status: json['payment_status'],
      payment_time: json['payment_time'],
    );
  }
}
