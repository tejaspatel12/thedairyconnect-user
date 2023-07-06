
import 'package:flutter/material.dart';
class BannerList {
  final String banner_id;
  final String banner_img;
  final String banner_status;


  BannerList({
    @required this.banner_id,
    @required this.banner_img,
    @required this.banner_status,
  });

  factory BannerList.fromJson(Map<String, dynamic> json) {
    return BannerList(
      banner_id: json['banner_id'],
      banner_img: json['banner_img'],
      banner_status: json['banner_status'],
    );
  }
}
