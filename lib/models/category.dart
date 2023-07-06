import 'package:flutter/material.dart';
class CategoryList {
  final String category_id;
  final String category_name;
  final String category_img;
  final String category_status;


  CategoryList({
    @required this.category_id,
    @required this.category_name,
    @required this.category_img,
    @required this.category_status,
  });

  factory CategoryList.fromJson(Map<String, dynamic> json) {
    return CategoryList(
      category_id: json['category_id'],
      category_name: json['category_name'],
      category_img: json['category_img'],
      category_status: json['category_status'],
    );
  }
}
