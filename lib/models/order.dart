
import 'package:flutter/material.dart';
class OrderList {
  final String order_id;
  final String user_id;
  final String product_id;
  final String attribute_id;
  final String category_id;
  final String product_name;
  final String product_image;
  final String product_des;
  final String product_price;
  final String product_status;
  final String attribute_name;
  final String attribute_status;
  final String attribute_value;
  final String start_date;
  final String category_name;
  final String delivery_schedule;
  final String order_instructions;
  final String order_ring_bell;
  final String added_time;
  final String ds_qty;
  final String ds_alt_diff;
  final String ds_Sun;
  final String ds_Mon;
  final String ds_Tue;
  final String ds_Wed;
  final String ds_Thu;
  final String ds_Fri;
  final String ds_Sat;
  final String user_balance;
  final String order_subscription_status;
  final String resume_date;
  final String push_date;


  OrderList({
    @required this.order_id,
    @required this.user_id,
    @required this.product_id,
    @required this.attribute_id,
    @required this.category_id,
    @required this.product_name,
    @required this.product_image,
    @required this.product_des,
    @required this.product_price,
    @required this.product_status,
    @required this.attribute_name,
    @required this.attribute_status,
    @required this.attribute_value,
    @required this.start_date,
    @required this.category_name,
    @required this.delivery_schedule,
    @required this.order_instructions,
    @required this.order_ring_bell,
    @required this.added_time,
    @required this.ds_qty,
    @required this.ds_alt_diff,
    @required this.ds_Sun,
    @required this.ds_Mon,
    @required this.ds_Tue,
    @required this.ds_Wed,
    @required this.ds_Thu,
    @required this.ds_Fri,
    @required this.ds_Sat,
    @required this.user_balance,
    @required this.order_subscription_status,
    @required this.resume_date,
    @required this.push_date,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) {
    return OrderList(
      order_id: json['order_id'],
      user_id: json['user_id'],
      product_id: json['product_id'],
      attribute_id: json['attribute_id'],
      category_id: json['category_id'],
      product_name: json['product_name'],
      product_image: json['product_image'],
      product_des: json['product_des'],
      product_price: json['product_price'],
      product_status: json['product_status'],
      attribute_name: json['attribute_name'],
      attribute_status: json['attribute_status'],
      attribute_value: json['attribute_value'],
      start_date: json['start_date'],
      category_name: json['category_name'],
      delivery_schedule: json['delivery_schedule'],
      order_instructions: json['order_instructions'],
      order_ring_bell: json['order_ring_bell'],
      added_time: json['added_time'],
      ds_qty: json['ds_qty'],
      ds_alt_diff: json['ds_alt_diff'],
      ds_Sun: json['ds_Sun'],
      ds_Mon: json['ds_Mon'],
      ds_Tue: json['ds_Tue'],
      ds_Wed: json['ds_Wed'],
      ds_Thu: json['ds_Thu'],
      ds_Fri: json['ds_Fri'],
      ds_Sat: json['ds_Sat'],
      user_balance: json['user_balance'],
      order_subscription_status: json['order_subscription_status'],
      resume_date: json['resume_date'],
      push_date: json['push_date'],
    );
  }
}
