
import 'package:flutter/material.dart';
class ProductList {
  final String product_id;
  final String product_name;
  final String product_image;
  final String product_des;
  final String product_regular_price;
  final String product_normal_price;
  final String product_type;
  final String product_status;
  final String attribute_id;
  final String attribute_name;
  final String attribute_status;
  final String attribute_price;
  final String attribute_value;
  final String product_att_value;
  final String product_already;


  ProductList({
    @required this.product_id,
    @required this.product_name,
    @required this.product_image,
    @required this.product_des,
    @required this.product_regular_price,
    @required this.product_normal_price,
    @required this.product_type,
    @required this.product_status,
    @required this.attribute_id,
    @required this.attribute_name,
    @required this.attribute_status,
    @required this.attribute_price,
    @required this.attribute_value,
    @required this.product_att_value,
    @required this.product_already,
  });

  factory ProductList.fromJson(Map<String, dynamic> json) {
    return ProductList(
      product_id: json['product_id'],
      product_name: json['product_name'],
      product_image: json['product_image'],
      product_des: json['product_des'],
      product_regular_price: json['product_regular_price'],
      product_normal_price: json['product_normal_price'],
      product_type: json['product_type'],
      product_status: json['product_status'],
      attribute_id: json['attribute_id'],
      attribute_name: json['attribute_name'],
      attribute_status: json['attribute_status'],
      attribute_price: json['attribute_price'],
      attribute_value: json['attribute_value'],
      product_att_value: json['product_att_value'],
      product_already: json['product_already'],
    );
  }
}
