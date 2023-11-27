import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dairy_connect/models/admin.dart';
import 'package:dairy_connect/models/user.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final BASE_URL = "https://7047cem.activeit.in/";

  static final BASE_URL_APP = BASE_URL + "api/";
  static final CATEGORY_BASE_URL_APP = BASE_URL + "api/admin/product/category/";
  static final SUBCATEGORY_BASE_URL_APP = BASE_URL + "api/admin/product/subcategory/";
  static final PRODUCT_BASE_URL_APP = BASE_URL + "api/admin/product/product/";
  static final SERVICE_BASE_URL_APP = BASE_URL + "api/admin/service/";

  static final APP_SETTING = BASE_URL_APP + "app_setting.php";
  static final GET_USER_DASHBOARD = BASE_URL_APP + "client_dashboard.php";
  static final LOGIN = BASE_URL_APP + "login.php";
  static final LOCATION = BASE_URL_APP + "location.php";
  static final CATEGORY = BASE_URL_APP + "category.php";
  static final PRODUCT = BASE_URL_APP + "product.php";
  static final USER = BASE_URL_APP + "user.php";
  static final ORDER = BASE_URL_APP + "order.php";
  static final RESUME_ORDER = BASE_URL_APP + "resume_order.php";
  static final ONETIME_ORDER = BASE_URL_APP + "onetime_order.php";
  static final UPDATE_ORDER = BASE_URL_APP + "update_order.php";
  static final PAYMENT = BASE_URL_APP + "payment.php";
  static final INVOICE = BASE_URL_APP + "invoice.php";
  static final CALENDAR = BASE_URL_APP + "calendar.php";
  static final FAQ = BASE_URL_APP + "faq.php";
  static final RECHARGE_OFFER = BASE_URL_APP + "recharge_offer.php";
  static final NOTIFICATION = BASE_URL_APP + "notification.php";
  static final BANNER = BASE_URL_APP + "banner.php";
  static final PASSWORD = BASE_URL_APP + "password.php";
  static final ORDERID = BASE_URL + "razorpay/pay.php";
  // static final GET_APP = BASE_URL_APP + "app_setting.php";

  static final BASE_INDEX = BASE_URL_APP + "index.php";
  static final GET_BANNER = BASE_URL_APP + "slider.php";

  static final GET_CUTOFF = BASE_URL_APP + "cutoff.php";

  //PRODUCT CODE
  //Category
  static final GET_DASHBOARD = BASE_URL_APP + "deliveryboy_order.php";
  static final GET_CATEGORY_DASHBOARD = BASE_URL_APP + "category.php";
  static final GET_PRODUCT_DASHBOARD = BASE_URL_APP + "product.php";

  static final GET_CATEGORY = CATEGORY_BASE_URL_APP + "get_category.php";
  static final DELETE_CATEGORY = CATEGORY_BASE_URL_APP + "delete_category.php";
  static final MANAGE_CATEGORY = CATEGORY_BASE_URL_APP + "manage_category.php";

  //Sub-Category
  static final SUBCATEGORY = SUBCATEGORY_BASE_URL_APP + "subcategory.php";

  //Service
  static final GET_SERVICE_DASHBOARD = SERVICE_BASE_URL_APP + "service_dashboard.php";
  static final SERVICE = SERVICE_BASE_URL_APP + "service.php";


  static final GET_ABOUT = BASE_URL_APP + "about.php";
  static final GET_SERVICE = BASE_URL_APP + "service.php";
  static final GET_PROJECT = BASE_URL_APP + "project.php";

  static final GET_PRODUCT = BASE_URL_APP + "product.php";
  static final GET_PRODUCT_ALL_DETAIL = BASE_URL_APP + "product_detail.php";

  static final GET_OFFER = BASE_URL_APP + "offer.php";
  static final GET_GALLERY = BASE_URL_APP + "gallery.php";

  static final SEND_APPOINTMENT = BASE_URL_APP + "send_appointment.php";

  static final SEND_SERVICE_INQUIRY = BASE_URL_APP + "send_service_inquiry.php";

  static final SEND_PRODUCT_INQUIRY = BASE_URL_APP + "send_product_inquiry.php";

  static final SEND_OFFER_INQUIRY = BASE_URL_APP + "send_offer_inquiry.php";

  static final SEND_CONTACT_US = BASE_URL_APP + "send_contact.php";


  // Image Path

  static final SLIDER_IMAGE = BASE_URL + "images/slider/";
  static final PRODUCT_IMAGE = BASE_URL + "images/product/";
  static final MORE_IMAGE = BASE_URL + "images/more/";
  static final CATEGORY_IMAGE = BASE_URL + "images/category/";
  static final AREA_IMAGE = BASE_URL + "images/area/";

  Future<Admin> login(String user_id, String otp, String user_token) {
    return _netUtil.post(LOGIN, body: {
      "action":"userlogin",
      // "last_id": last_id,
      "user_mobile_number": user_id,
      "user_password": otp,
      "user_token": user_token,
    }).then((dynamic res) async {
      print(res.toString());
      // if(res["status"]=="no") throw new Exception(res["message"]);
      if(res["status"]=="no") throw Fluttertoast.showToast(msg: res['message'], toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: maincolor, fontSize: 16.0);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user_id", res["data"]["user_id"]);
      prefs.setString("user_first_name", res["data"]["user_first_name"]);
      prefs.setString("user_last_name", res["data"]["user_last_name"]);
      prefs.setString("user_mobile_number", res["data"]["user_mobile_number"]);
      return new Admin.map(res["data"]);
    });
  }

}