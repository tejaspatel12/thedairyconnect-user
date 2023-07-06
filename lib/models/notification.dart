
import 'package:flutter/material.dart';
class NotificationList {
  final String notification_id;
  final String notification_title;
  final String notification_des;
  final String notification_status;


  NotificationList({
    @required this.notification_id,
    @required this.notification_title,
    @required this.notification_des,
    @required this.notification_status,
  });

  factory NotificationList.fromJson(Map<String, dynamic> json) {
    return NotificationList(
      notification_id: json['notification_id'],
      notification_title: json['notification_title'],
      notification_des: json['notification_des'],
      notification_status: json['notification_status'],
    );
  }
}
