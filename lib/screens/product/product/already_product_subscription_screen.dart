import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/models/category.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class AlreadyProductSubscriptionDetailScreen extends StatefulWidget {
  final String product_id,product_name;
  const AlreadyProductSubscriptionDetailScreen({Key key, @required this.product_id, @required this.product_name}) : super(key: key);
  // UserNotSubscriptionProductScreenState createState() => UserNotSubscriptionProductScreenState();
  State<AlreadyProductSubscriptionDetailScreen> createState() => AlreadyProductSubscriptionDetailScreenState(product_id,product_name);

  // @override
  // _AlreadyProductSubscriptionDetailScreenState createState() => _AlreadyProductSubscriptionDetailScreenState();
}

class AlreadyProductSubscriptionDetailScreenState extends State<AlreadyProductSubscriptionDetailScreen> {
  BuildContext _ctx;

  String product_id,product_name;
  AlreadyProductSubscriptionDetailScreenState(this.product_id,this.product_name);


  NetworkUtil _netUtil = new NetworkUtil();

  bool _isLoading = true;
  bool _isdataLoading = true;
  bool _isdataUser = true;
  bool _isProccessing = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String attribute_value,product_image,category_id,category_name,product_type,product_des,product_status,featured_product,attribute_id,attribute_name;
  String user_first_name,user_last_name,user_type,user_subscription_status;
  String ds_type,order_id=null,order_instructions,order_ring_bell,start_date,ds_alt_diff;
  String newdate,user_status,accept_nagative_balance,user_balance,product_att_value;
  
  int num = 0, us=0,olx=0;
  int day = 0,alt = 2;
  int size = 1,product_min_qty;
  String user_id;
  String notification = "1",_Instructions,time_slot,cutoff_time=null;
  String stopsubscription="0";
  String cutoff_1,cutoff_2;
  int count = 0;
  int ds_qty = 0;
  double product_normal_price,product_regular_price,mainprice,finalprice;

  
  DateTime dateTime,StopdateTime;
  DateTime mordate=DateTime.now();

  TextEditingController order_instructions_namecontroller=new TextEditingController();

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString("user_id") ?? '';
      // print("user_id : "+user_id);
      _netUtil.post(RestDatasource.PRODUCT, body: {
        'action': "get_already_product_detail",
        'product_id': product_id,
        'user_id': user_id,
      }).then((dynamic res) async {
        setState(() {
          num= 1;
          // print(res);
          product_image = res[0]["product_image"];
          category_id = res[0]["category_id"];
          category_name = res[0]["category_name"];
          attribute_value = res[0]["attribute_value"];
          product_regular_price = res[0]["product_regular_price"].toDouble();
          product_normal_price = res[0]["product_normal_price"].toDouble();
          product_des = res[0]["product_des"];
          product_status = res[0]["product_status"];
          featured_product = res[0]["featured_product"];
          attribute_id = res[0]["attribute_id"];
          attribute_name = res[0]["attribute_name"];
          product_att_value = res[0]["product_att_value"];
          product_type = res[0]["product_type"];
          product_min_qty = res[0]["product_min_qty"].toInt();
          product_min_qty = res[0]["product_min_qty"];

          order_id = res[0]["order_id"];
          ds_type = res[0]["ds_type"];
          start_date = res[0]["start_date"];
          ds_alt_diff = res[0]["ds_alt_diff"];
          order_instructions = res[0]["order_instructions"];
          order_ring_bell = res[0]["order_ring_bell"];
          ds_qty = res[0]["ds_qty"].toInt();

          count = product_min_qty;

          print("order_id : "+order_id);
          order_instructions_namecontroller.text = order_instructions;

          // product_status = res[0]["product_status"];
          // featured_product = res[0]["featured_product"];
          _isdataLoading = false;
        });
      });
    });
  }


  // _loadPref() async {
  //   _netUtil.post(RestDatasource.PRODUCT, body: {
  //     'action': "get_already_product_detail",
  //     'product_id': product_id,
  //     'user_id': user_id,
  //   }).then((dynamic res) async {
  //     // print(res);
  //     setState(() {
  //       num = 1;
  //       // product_name = res[0]["product_name"];
  //       product_image = res[0]["product_image"];
  //       category_id = res[0]["category_id"];
  //       category_name = res[0]["category_name"];
  //       attribute_value = res[0]["attribute_value"];
  //       product_regular_price = res[0]["product_regular_price"].toDouble();
  //       product_normal_price = res[0]["product_normal_price"].toDouble();
  //       product_des = res[0]["product_des"];
  //       product_status = res[0]["product_status"];
  //       featured_product = res[0]["featured_product"];
  //       attribute_id = res[0]["attribute_id"];
  //       attribute_name = res[0]["attribute_name"];
  //       product_att_value = res[0]["product_att_value"];
  //       product_type = res[0]["product_type"];
  //       product_min_qty = res[0]["product_min_qty"].toInt();
  //       product_min_qty = res[0]["product_min_qty"];
  //       count = product_min_qty;
  //
  //       order_id = res["0"]["order_id"];
  //       ds_type = res["0"]["ds_type"];
  //       start_date = res["0"]["start_date"];
  //       ds_alt_diff = res["0"]["ds_alt_diff"];
  //       order_instructions = res["0"]["order_instructions"];
  //       order_ring_bell = res["0"]["order_ring_bell"];
  //       print("order_id : "+order_id);
  //       order_instructions_namecontroller.text = order_instructions;
  //
  //       // product_status = res[0]["product_status"];
  //       // featured_product = res[0]["featured_product"];
  //       _isdataLoading = false;
  //
  //     });
  //   });
  // }



  _loadUserTime() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString("user_id") ?? '';
      // print("user_id : "+user_id);
      _netUtil.post(RestDatasource.GET_USER_DASHBOARD, body: {
        "user_id": user_id,
      }).then((dynamic res) async {
        setState(() {
          us= 1;
          // print(res);
          user_status = res["user_status"];
          time_slot = res["time_slot"].toString();
          print("time_slot : $time_slot");
          if(user_status=="1")
          {
            user_first_name = res["user_first_name"].toString();
            user_last_name = res["user_last_name"].toString();
            user_type = res["user_type"].toString();
            user_subscription_status = res["user_subscription_status"].toString();
            accept_nagative_balance = res["accept_nagative_balance"].toString();
            user_balance = res["user_balance"].toString();

            //
            time_slot = res["time_slot"].toString();
            cutoff_time = res["cutoff_time"].toString();

            cutoff_1 = res["cutoff_1"].toString();
            cutoff_2 = res["cutoff_2"].toString();
            newdate = DateFormat('yyyy-MM-dd').format(dateTime).toString();
            newdate = newdate+" "+ cutoff_time;
            // print("time_slot "+time_slot);
            // print("user_status "+user_status);
            print("newdate : "+newdate.toString());
            // newdate = DateFormat('yyyy-MM-dd H:mm:ss').format(newdate).toString();

            if(cutoff_time==cutoff_1)
            {
              // print("NEW "+newdate.toString());
              // print("MOR "+DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString());

              DateTime.parse(newdate.toString()).isBefore
                (DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString()))==false?
              mordate=dateTime:
              mordate=dateTime.add(Duration(days: 1));
            }
            else if(cutoff_time==cutoff_2)
            {
              DateTime.parse(newdate.toString()).isBefore
                (DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)))==false?
              // (DateTime.parse(dateTime.toString()))==false?
              mordate=dateTime:
              mordate=dateTime.add(Duration(days: 1));
            }
            else{}
          }
          else{

          }

          _isdataUser = false;
        });
      });
    });
  }



  // _loadUserTime() async {
  //   prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     user_id = prefs.getString("user_id") ?? '';
  //     // print("user_id : "+user_id);
  //     _netUtil.post(RestDatasource.GET_USER_DASHBOARD, body: {
  //       "user_id": user_id,
  //     }).then((dynamic res) async {
  //       setState(() {
  //         us= 1;
  //         // print(res);
  //         user_status = res["user_status"];
  //         time_slot = res["time_slot"].toString();
  //         print("time_slot : $time_slot");
  //         if(user_status=="1")
  //         {
  //           user_first_name = res["user_first_name"].toString();
  //           user_last_name = res["user_last_name"].toString();
  //           user_type = res["user_type"].toString();
  //           user_subscription_status = res["user_subscription_status"].toString();
  //           accept_nagative_balance = res["accept_nagative_balance"].toString();
  //           user_balance = res["user_balance"].toString();
  //
  //           //
  //           time_slot = res["time_slot"].toString();
  //           cutoff_time = res["cutoff_time"].toString();
  //
  //           cutoff_1 = res["cutoff_1"].toString();
  //           cutoff_2 = res["cutoff_2"].toString();
  //           newdate = DateFormat('yyyy-MM-dd').format(dateTime).toString();
  //           newdate = newdate+" "+ cutoff_time;
  //           // print("time_slot "+time_slot);
  //           // print("user_status "+user_status);
  //
  //           // newdate = DateFormat('yyyy-MM-dd H:mm:ss').format(newdate).toString();
  //
  //           if(cutoff_time==cutoff_1)
  //           {
  //             // print("NEW "+newdate.toString());
  //             // print("MOR "+DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString());
  //
  //             DateTime.parse(newdate.toString()).isBefore
  //               (DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime).toString()))==false?
  //             mordate=dateTime:
  //             mordate=dateTime.add(Duration(days: 1));
  //           }
  //           else if(cutoff_time==cutoff_2)
  //           {
  //             DateTime.parse(newdate.toString()).isBefore
  //               (DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)))==false?
  //             // (DateTime.parse(dateTime.toString()))==false?
  //             mordate=dateTime:
  //             mordate=dateTime.add(Duration(days: 1));
  //           }
  //           else{}
  //         }
  //         else{
  //
  //         }
  //
  //
  //         _isdataUser = false;
  //       });
  //     });
  //   });
  // }


  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    super.initState();
    dateTime = DateTime.now();
    StopdateTime = DateTime.now();
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadUserTime();
    _loadPref();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    // setState(() {
    //   _ctx = context;
    //   final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
    //   product_id = arguments['product_id'];
    //   product_name = arguments['product_name'];
    //   // print("product_id = "+ product_id);
    //   num == 0 ? _loadPref() : null;
    //   // user_id != null ? _loadUserTime() : null;
    //   us == 0 ? _loadUserTime() : null;
    //   // _loadPref();
    // });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: shadecolor,
        key: scaffoldKey,
        body: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (BuildContext context,
                  bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    centerTitle: true,
                    backgroundColor: maincolor,
                    title: Text(product_name==null?"":product_name,
                      style: TextStyle(color: Colors.white),),
                    iconTheme: IconThemeData(color: Colors.white),

                    pinned: true,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                  ),
                ];
              },
              body: 
              (_isProccessing)?Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/proccessing.json',
                    repeat: true,
                    reverse: true,
                    animate: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Just Minute..."),
                ],
              ):(_isdataUser)
                  ? new Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  repeat: true,
                  reverse: true,
                  animate: true,
                ),

              ):(_isdataLoading)
                  ? new Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  repeat: true,
                  reverse: true,
                  animate: true,
                ),

              ):
               ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 0),
                children: <Widget>[
                  Column(
                    children: <Widget>[

                      Container(
                        // padding: EdgeInsets.symmetric(
                        //     vertical: 10, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Column(
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[

                                      Container(
                                        height: 230.0,
                                        width: double.infinity,
                                        margin: EdgeInsets.symmetric(horizontal: 0.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          // color: maincolor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0.0),
                                            topRight: Radius.circular(0.0),
                                            bottomLeft: Radius.circular(20.0),
                                            bottomRight: Radius.circular(20.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.06),
                                              blurRadius: 15.0,
                                              offset: Offset(1, 10.0),
                                              spreadRadius: 2.0,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15.0),
                                          child: product_image!=null?
                                          Image.network(RestDatasource.PRODUCT_IMAGE + product_image,width: MediaQuery.of(context).size.width,
                                          ):Image.asset('images/logo.png', width: MediaQuery.of(context).size.width,),
                                        ),
                                      ),

                                      SizedBox(
                                        height: spacing_normal,
                                      ),

                                      Form(
                                        key: formKey,
                                        child: Container(
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20.0),
                                                topRight: Radius.circular(20.0),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              boxShadow: [BoxShadow(
                                                color: bordercolor,
                                                blurRadius: 5.0,
                                              ),],
                                              color: whitecolor,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: textSizeNormal,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(product_name==null?"":product_name, style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),

                                                          const SizedBox(
                                                            height: spacing_middle,
                                                          ),

                                                          // product_type=="1"?
                                                          Row(
                                                            children: [
                                                              user_type=="1"?
                                                              Text(product_regular_price==null?"":"£"+product_regular_price.toString()+"/", style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)):
                                                              Text(product_normal_price==null?"":"£"+product_normal_price.toString()+"/", style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)),

                                                              Text(product_att_value==null?"":product_att_value+" ", style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)),
                                                              Text(attribute_name==null?"":attribute_name, style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)),
                                                            ],
                                                          ),
                                                          // :
                                                          // Row(
                                                          //   children: [
                                                          //     Text(product_normal_price==null?"":"£"+product_normal_price.toString()+"/", style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)),
                                                          //
                                                          //     Text(attribute_name==null?"":"500 "+attribute_name, style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)),
                                                          //   ],
                                                          // ),

                                                          const SizedBox(
                                                            height: spacing_middle,
                                                          ),
                                                          
                                                          Container(
                                                            decoration: const BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(5.0),
                                                                topRight: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0),
                                                              ),
                                                              color: greencolor,
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: Text(
                                                                "Subscribed".toUpperCase(),
                                                                style: const TextStyle(
                                                                  color: whitecolor,
                                                                  fontSize: 12.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                            height: spacing_middle,
                                                          ),
                                                          const Text("Produced by "+ apptitle, style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)),
                                                        ],
                                                      ),


                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: spacing_middle,
                                                ),


                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const SizedBox(
                                                        height: spacing_middle,
                                                      ),
                                                      Container(
                                                          color : shadecolor,
                                                          child: Padding(
                                                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                            child: Row(
                                                              children: [
                                                                const Text("Description", style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                              ],
                                                            ),
                                                          )
                                                      ),
                                                      const SizedBox(
                                                        height: spacing_middle,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                        child: Html(
                                                            data: product_des==null?"":product_des,
                                                            style: {
                                                              // text that renders h1 elements will be red
                                                              // "p": Style(color: textcolor,fontSize: FontSize.smaller, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                                                            }
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: spacing_middle,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                time_slot!="No"?
                                                Column(
                                                  children: [
                                                    cutoff_time==cutoff_1?
                                                    Container(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            height: spacing_control,
                                                          ),


                                                          Container(
                                                              color : shadecolor,
                                                              child: Padding(
                                                                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text("Update Date", style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                    // Text("Cut-off : "+newdate, style: TextStyle(color: redcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                  ],
                                                                ),
                                                              )
                                                          ),

                                                          SizedBox(
                                                            height: spacing_standard_new,
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Icon(Icons.today,size:textSizeNormal,color: titletext,),
                                                                    SizedBox(
                                                                      width: spacing_control,
                                                                    ),
                                                                    // DateTime.parse(newdate.toString()).isBefore
                                                                    //   (DateTime.parse(dateTime.toString()))==false?
                                                                    // Text(DateFormat('d-MM-yyy').format(dateTime.add(Duration(days: 1))), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)):
                                                                    // Text(DateFormat('d-MM-yyy').format(dateTime.add(Duration(days: 2))), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                    Text(DateFormat('d-MM-yyy').format(mordate), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5))
                                                                  ],
                                                                ),

                                                                DateTime.parse(newdate.toString()).isBefore
                                                                  (DateTime.parse(dateTime.toString()))==false?
                                                                InkWell(
                                                                    onTap:() async {
                                                                      DateTime newDateTime = await showRoundedDatePicker(
                                                                        context: context,
                                                                        initialDate: dateTime,
                                                                        firstDate: dateTime.subtract(Duration(days: 1)),
                                                                        lastDate: DateTime(DateTime.now().year + 1),
                                                                        borderRadius: 2,
                                                                      );
                                                                      if (newDateTime != null) {
                                                                        setState(() => mordate = newDateTime);
                                                                      }
                                                                    },
                                                                    child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                                ):
                                                                InkWell(
                                                                    onTap:() async {
                                                                      DateTime newDateTime = await showRoundedDatePicker(
                                                                        context: context,
                                                                        initialDate: dateTime.add(Duration(days: 1)),
                                                                        firstDate: dateTime,
                                                                        lastDate: DateTime(DateTime.now().year + 1),
                                                                        borderRadius: 2,
                                                                      );
                                                                      if (newDateTime != null) {
                                                                        setState(() => mordate = newDateTime);
                                                                      }
                                                                    },
                                                                    child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                                ),

                                                              ],
                                                            ),
                                                          ),

                                                          SizedBox(
                                                            height: spacing_middle,
                                                          ),
                                                        ],
                                                      ),
                                                    ):
                                                    cutoff_time==cutoff_2?
                                                    Container(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(
                                                            height: spacing_control,
                                                          ),


                                                          Container(
                                                              color : shadecolor,
                                                              child: Padding(
                                                                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text("Update Date", style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                    // Text("Cut-off : "+newdate, style: TextStyle(color: redcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                  ],
                                                                ),
                                                              )
                                                          ),

                                                          SizedBox(
                                                            height: spacing_standard_new,
                                                          ),

                                                          Padding(
                                                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Icon(Icons.today,size:textSizeNormal,color: titletext,),
                                                                    SizedBox(
                                                                      width: spacing_control,
                                                                    ),
                                                                    // DateTime.parse(newdate.toString()).isBefore
                                                                    //   (DateTime.parse(dateTime.toString()))==false?
                                                                    // Text(DateFormat('d-MM-yyy').format(dateTime.add(Duration(days: 1))), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)):
                                                                    // Text(DateFormat('d-MM-yyy').format(dateTime.add(Duration(days: 2))), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                    Text(DateFormat('d-MM-yyy').format(mordate), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5))
                                                                  ],
                                                                ),

                                                                DateTime.parse(newdate.toString()).isBefore
                                                                  (DateTime.parse(dateTime.toString()))==false?
                                                                InkWell(
                                                                    onTap:() async {
                                                                      DateTime newDateTime = await showRoundedDatePicker(
                                                                        context: context,
                                                                        initialDate: dateTime,
                                                                        firstDate: dateTime.subtract(Duration(days: 1)),
                                                                        lastDate: DateTime(DateTime.now().year + 1),
                                                                        borderRadius: 2,
                                                                      );
                                                                      if (newDateTime != null) {
                                                                        setState(() => mordate = newDateTime);
                                                                      }
                                                                    },
                                                                    child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                                ):
                                                                InkWell(
                                                                    onTap:() async {
                                                                      DateTime newDateTime = await showRoundedDatePicker(
                                                                        context: context,
                                                                        initialDate: dateTime.add(Duration(days: 1)),
                                                                        firstDate: dateTime,
                                                                        lastDate: DateTime(DateTime.now().year + 1),
                                                                        borderRadius: 2,
                                                                      );
                                                                      if (newDateTime != null) {
                                                                        setState(() => mordate = newDateTime);
                                                                      }
                                                                    },
                                                                    child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                                ),

                                                              ],
                                                            ),
                                                          ),

                                                          // Padding(
                                                          //   padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                          //   child: Row(
                                                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          //     crossAxisAlignment: CrossAxisAlignment.start,
                                                          //     children: [
                                                          //       Row(
                                                          //         children: [
                                                          //           Icon(Icons.today,size:textSizeNormal,color: titletext,),
                                                          //           SizedBox(
                                                          //             width: spacing_control,
                                                          //           ),
                                                          //           // DateTime.parse(newdate.toString()).isBefore
                                                          //           //   (DateTime.parse(dateTime.toString()))==false?
                                                          //           // Text(DateFormat('d-MM-yyy').format(dateTime), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)):
                                                          //           // Text(DateFormat('d-MM-yyy').format(dateTime.add(Duration(days: 1))), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                          //           Text(DateFormat('d-MM-yyy').format(mordate), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5))
                                                          //         ],
                                                          //       ),
                                                          //
                                                          //       DateTime.parse(newdate.toString()).isBefore
                                                          //         (DateTime.parse(dateTime.toString()))==false?
                                                          //       InkWell(
                                                          //           onTap:() async {
                                                          //             DateTime newDateTime = await showRoundedDatePicker(
                                                          //               context: context,
                                                          //               initialDate: dateTime,
                                                          //               firstDate: dateTime.subtract(Duration(days: 1)),
                                                          //               lastDate: DateTime(DateTime.now().year + 1),
                                                          //               borderRadius: 2,
                                                          //             );
                                                          //             if (newDateTime != null) {
                                                          //               setState(() => mordate = newDateTime);
                                                          //             }
                                                          //           },
                                                          //           child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                          //       ):InkWell(
                                                          //           onTap:() async {
                                                          //             DateTime newDateTime = await showRoundedDatePicker(
                                                          //               context: context,
                                                          //               initialDate: dateTime.add(Duration(days: 1)),
                                                          //               firstDate: dateTime,
                                                          //               lastDate: DateTime(DateTime.now().year + 1),
                                                          //               borderRadius: 2,
                                                          //             );
                                                          //             if (newDateTime != null) {
                                                          //               setState(() => mordate = newDateTime);
                                                          //             }
                                                          //           },
                                                          //           child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                                          //       )
                                                          //
                                                          //     ],
                                                          //   ),
                                                          // ),

                                                          SizedBox(
                                                            height: spacing_middle,
                                                          ),
                                                        ],
                                                      ),
                                                    ):SizedBox(),
                                                  ],
                                                ):SizedBox(),


                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        height: spacing_control,
                                                      ),

                                                      Container(
                                                          color : shadecolor,
                                                          child: Padding(
                                                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                            child: Row(
                                                              children: [
                                                                Text("Delivery Schedule", style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                // SizedBox(
                                                                //   width: spacing_standard,
                                                                // ),
                                                                // Text(cutoff_time==null?"":"(Cut-off Time is "+cutoff_time+")", style: TextStyle(color: redcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                              ],
                                                            ),
                                                          )
                                                      ),
                                                      SizedBox(
                                                        height: spacing_middle,
                                                      ),
                                                      // Column(
                                                      //   mainAxisAlignment: MainAxisAlignment.center,
                                                      //   crossAxisAlignment: CrossAxisAlignment.center,
                                                      //   children: [
                                                      //     Text(DateFormat('d-MM-yyy').format(dateTime).toString(), style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                      //   ],
                                                      // ),
                                                      // SizedBox(
                                                      //   height: spacing_middle,
                                                      // ),

                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          ds_type=="Everyday"?Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(20),
                                                                color: maincolor,
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.fromLTRB(15, 7, 15, 7),
                                                                child: Text("Everyday", style: TextStyle(color: whitecolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                                              )):SizedBox(),
                                                        ],
                                                      ),

                                                      SizedBox(
                                                        height: spacing_standard_new,
                                                      ),

                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [

                                                          InkWell(
                                                            onTap: (){
                                                              setState(() {
                                                                // int.parse(price);
                                                                if(ds_qty <= 1)
                                                                {

                                                                }
                                                                else
                                                                {
                                                                  ds_qty = product_min_qty;
                                                                }

                                                              });
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(5.0),
                                                                  topRight: Radius.circular(5.0),
                                                                  bottomLeft: Radius.circular(5.0),
                                                                  bottomRight: Radius.circular(5.0),
                                                                ),
                                                                color: maincolor, //
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                                child: Icon(Icons.remove,size:textSizeMedium,color: whitecolor,),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: spacing_standard,
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(15, 7, 15, 7),
                                                            child: Text(ds_qty.toString(),
                                                              style: TextStyle(
                                                                color: maincolor,
                                                                fontSize: textSizeSMedium,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: spacing_standard,
                                                          ),
                                                          InkWell(
                                                            onTap: (){
                                                              setState(() {
                                                                // int.parse(price);
                                                                // if(ds_qty >= 10)
                                                                // {
                                                                // }
                                                                // else if(ds_qty == 0)
                                                                // {
                                                                //   ds_qty = product_min_qty;
                                                                // }
                                                                // else
                                                                // {
                                                                //   ds_qty = ds_qty+1;
                                                                // }

                                                                if(ds_qty == 0)
                                                                {
                                                                  ds_qty = product_min_qty;
                                                                }
                                                                else
                                                                {
                                                                  ds_qty = ds_qty+1;
                                                                }

                                                              });
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(5.0),
                                                                  topRight: Radius.circular(5.0),
                                                                  bottomLeft: Radius.circular(5.0),
                                                                  bottomRight: Radius.circular(5.0),
                                                                ),
                                                                color: maincolor, //
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                                child: Icon(Icons.add,size:textSizeMedium,color: whitecolor,),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: spacing_standard,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text("Add Quantity",
                                                            style: TextStyle(
                                                              color: blackcolor,
                                                              fontSize: spacing_middle,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: spacing_standard,
                                                      ),
                                                    ],
                                                  ),
                                                ),


                                                

                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        height: spacing_control,
                                                      ),
                                                      Container(
                                                          color : shadecolor,
                                                          child: Padding(
                                                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                            child: Row(
                                                              children: [
                                                                Text("Instructions For Delivery Boy", style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                              ],
                                                            ),
                                                          )
                                                      ),
                                                      SizedBox(
                                                        height: spacing_standard_new,
                                                      ),

                                                      Padding(
                                                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                        child: TextFormField(
                                                            initialValue: null,
                                                            obscureText: false,
                                                            keyboardType: TextInputType.text,
                                                            controller: order_instructions_namecontroller,
                                                            onSaved: (val) {
                                                              setState(() {
                                                                order_instructions = val;
                                                              });
                                                            },
                                                            onChanged: (val) {
                                                              setState(() {
                                                                order_instructions = val;
                                                              });
                                                            },
                                                            decoration: InputDecoration(
                                                              // labelText: 'Enter Your Mobile Number',
                                                              hintText: '',
                                                              labelStyle: TextStyle(color: maincolor),
                                                              focusedBorder: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      width: 2, color: maincolor
                                                                  )
                                                              ),
                                                              border: OutlineInputBorder(
                                                                  borderSide: BorderSide()
                                                              ),
                                                              fillColor: shadecolor,
                                                              filled: true,
                                                              isDense: true,
                                                              contentPadding: EdgeInsets.fromLTRB(12, 14, 12, 14), )),
                                                      ),

                                                      SizedBox(
                                                        height: spacing_middle,
                                                      ),

                                                    ],
                                                  ),
                                                ),

                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        height: spacing_control,
                                                      ),
                                                      Container(
                                                          color : shadecolor,
                                                          child: Padding(
                                                            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                            child: Row(
                                                              children: [
                                                                Text("Ring the bell or not?", style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                              ],
                                                            ),
                                                          )
                                                      ),
                                                      SizedBox(
                                                        height: spacing_standard_new,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          InkWell(
                                                            onTap: (){
                                                              setState(() {
                                                                order_ring_bell = "1";
                                                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bell ring is on"),));
                                                                Fluttertoast.showToast(
                                                                    msg: 'Bell ring is on',
                                                                    gravity: ToastGravity.BOTTOM,
                                                                    backgroundColor: maincolor,
                                                                    textColor: whitecolor
                                                                );
                                                                // Toast.show("Bell ring is on", textStyle: context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM,textColor:maincolor,backgroundColor:whitecolor);
                                                              });
                                                            },
                                                            child: order_ring_bell=="1"?Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(5.0),
                                                                  topRight: Radius.circular(5.0),
                                                                  bottomLeft: Radius.circular(5.0),
                                                                  bottomRight: Radius.circular(5.0),
                                                                ),
                                                                color: maincolor, //
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                                child: Icon(Icons.notifications,size:textSizeLargeMedium,color: whitecolor,),
                                                              ),
                                                            ):Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(5.0),
                                                                  topRight: Radius.circular(5.0),
                                                                  bottomLeft: Radius.circular(5.0),
                                                                  bottomRight: Radius.circular(5.0),
                                                                ),
                                                                color: whitecolor, //
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                                child: Icon(Icons.notifications,size:textSizeLargeMedium,color: maincolor,),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: spacing_standard,
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.fromLTRB(
                                                                10, 20, 10, 20),
                                                            width: 0.5,
                                                            color: Colors.grey,
                                                          ),
                                                          SizedBox(
                                                            width: spacing_standard,
                                                          ),
                                                          InkWell(
                                                            onTap: (){
                                                              setState(() {
                                                                order_ring_bell = "0";
                                                                Fluttertoast.showToast(
                                                                    msg: 'Bell ring is off',
                                                                    gravity: ToastGravity.BOTTOM,
                                                                    backgroundColor: redcolor,
                                                                    textColor: whitecolor
                                                                );
                                                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bell ring is off"),));
                                                                // Toast.show("Bell ring is off", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM,textColor:redcolor,backgroundColor:whitecolor);
                                                              });
                                                            },
                                                            child: order_ring_bell == "0"?Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(5.0),
                                                                  topRight: Radius.circular(5.0),
                                                                  bottomLeft: Radius.circular(5.0),
                                                                  bottomRight: Radius.circular(5.0),
                                                                ),
                                                                color: maincolor, //
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                                child: Icon(Icons.notifications_off,size:textSizeLargeMedium,color: whitecolor,),
                                                              ),
                                                            ):Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(5.0),
                                                                  topRight: Radius.circular(5.0),
                                                                  bottomLeft: Radius.circular(5.0),
                                                                  bottomRight: Radius.circular(5.0),
                                                                ),
                                                                color: whitecolor, //
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                                child: Icon(Icons.notifications_off,size:textSizeLargeMedium,color: maincolor,),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      SizedBox(
                                                        height: spacing_middle,
                                                      ),

                                                    ],
                                                  ),
                                                ),


                                              ],)),
                                      ),

                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.01,
                                        color: maincolor,
                                      ),
                                      time_slot=="No"?
                                      Container(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(0.0),
                                              topRight: Radius.circular(0.0),
                                              bottomLeft: Radius.circular(15.0),
                                              bottomRight: Radius.circular(15.0),
                                            ),
                                            color: redcolor,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            child: Center(
                                              child: Text("Waiting for The Dairy App response",
                                                style: TextStyle(
                                                  color: whitecolor,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ):user_status=="2"?
                                      Container(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(0.0),
                                              topRight: Radius.circular(0.0),
                                              bottomLeft: Radius.circular(15.0),
                                              bottomRight: Radius.circular(15.0),
                                            ),
                                            color: redcolor,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                            child: Center(
                                              child: Text("We not provide any service in your area",
                                                style: TextStyle(
                                                  color: whitecolor,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ):SizedBox(),
                                      
                                      SizedBox(
                                        height: 100,
                                      ),


                                    ],
                                  ),




                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            user_status=="1"?Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                time_slot!="No"?Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    (user_balance=="0.00") && (accept_nagative_balance=="0")?
                    Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(25,15, 25, 10),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed("/wallet");
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5.0),
                                            topRight: Radius.circular(5.0),
                                            bottomLeft: Radius.circular(5.0),
                                            bottomRight: Radius.circular(5.0),
                                          ),
                                          color: maincolor,
                                        ),
                                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                        alignment: Alignment.center,
                                        child: Text("Recharge to place order".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                    ):
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        user_subscription_status=="0"?SizedBox():_isProccessing?SizedBox():order_id!=null?
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[

                            Container(
                              color: whitecolor,
                              child:  InkWell(
                                onTap: () {
                                  if(ds_type=="Everyday")
                                  {
                                    if(ds_qty < product_min_qty)
                                    {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              Dialog(
                                                backgroundColor: Colors.white,
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                        padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .center,
                                                          children: <Widget>[
                                                            Lottie.asset(
                                                              'assets/stop.json',
                                                              repeat: true,
                                                              reverse: false,
                                                              animate: true,
                                                              height: MediaQuery.of(context).size.height * 0.40,
                                                            ),
                                                            SizedBox(
                                                              height: spacing_standard,
                                                            ),
                                                            Align(
                                                                alignment: Alignment.center,
                                                                child: Text("Minimum Quantity", style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold,color: maincolor),)
                                                            ),
                                                            SizedBox(
                                                              height: spacing_middle,
                                                            ),
                                                            Align(
                                                              alignment: Alignment.center,
                                                              child: Text(
                                                                "You should add at less "+ product_min_qty.toString() +" quantity",
                                                                style: TextStyle(
                                                                    fontSize: textSizeMMedium,fontWeight: FontWeight.w500, letterSpacing: 0.2
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: spacing_standard,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Divider(
                                                      //   color: Colors.grey,
                                                      // ),
                                                      Row(
                                                        children: <Widget>[

                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: ()
                                                              {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(10.0),
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                      topLeft: Radius.circular(5.0),
                                                                      topRight: Radius.circular(5.0),
                                                                      bottomLeft: Radius.circular(5.0),
                                                                      bottomRight: Radius.circular(5.0),
                                                                    ),
                                                                    color: maincolor,
                                                                  ),
                                                                  padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                                                                  alignment: Alignment.center,
                                                                  child: Text("Ok",style: TextStyle(fontSize: textSizeMedium,color:Colors.white,fontWeight: FontWeight.w600),),
                                                                ),
                                                              ),
                                                            ),

                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                      );
                                    }
                                    else
                                    {
                                      // if(DateTime.parse(cutoff_time.toString()).isBefore(DateTime.parse(DateFormat('H:mm:ss').format(dateTime)))==false)
                                      // {
                                      //   FlashHelper.errorBar(context, message: "1");
                                      // }
                                      // else
                                      //   {
                                      //     FlashHelper.errorBar(context, message: "2");
                                      //   }

                                      if (_isProccessing == false) {
                                        final form = formKey.currentState;
                                        if (form.validate()) {
                                          setState(() => _isProccessing = true);
                                          form.save();
                                          NetworkUtil _netUtil = new NetworkUtil();
                                          _netUtil.post(RestDatasource.UPDATE_ORDER, body: {
                                            'action': "update_order_everyday_subscription_product",
                                            "user_id": user_id,
                                            "order_id": order_id,
                                            "product_name": product_name,
                                            "cutoff_time": cutoff_time,
                                            "product_price": user_type=="1"?product_regular_price.toString():product_normal_price.toString(),
                                            "qty": ds_qty.toString(),
                                            "start_date": DateFormat('yyyy-MM-dd').format(mordate).toString(),
                                            // "start_date": DateTime.parse(cutoff_time).isBefore(dateTime)?DateFormat('yyyy-MM-dd').format(dateTime).toString():DateFormat('yyyy-MM-dd').format(dateTime.add(Duration(days: 1))).toString(),
                                            "order_instructions": order_instructions,
                                            "order_ring_bell": order_ring_bell,
                                          }).then((dynamic res) async {
                                            if(res["status"] == "insufficient_balance")
                                            {
                                              setState(() => _isProccessing = false);
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      Dialog(
                                                        backgroundColor: Colors.white,
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              Container(
                                                                padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment
                                                                      .center,
                                                                  children: <Widget>[
                                                                    Lottie.asset(
                                                                      'assets/stop.json',
                                                                      repeat: true,
                                                                      reverse: false,
                                                                      animate: true,
                                                                      height: MediaQuery.of(context).size.height * 0.40,
                                                                    ),
                                                                    SizedBox(
                                                                      height: spacing_standard,
                                                                    ),
                                                                    Align(
                                                                        alignment: Alignment.center,
                                                                        child: Text(res['message'], style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold,color: maincolor),)
                                                                    ),
                                                                    SizedBox(
                                                                      height: spacing_middle,
                                                                    ),
                                                                    Align(
                                                                      alignment: Alignment.center,
                                                                      child: Text(
                                                                        res['description'],
                                                                        style: TextStyle(
                                                                            fontSize: textSizeMMedium,fontWeight: FontWeight.w500, letterSpacing: 0.2
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: spacing_standard,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              // Divider(
                                                              //   color: Colors.grey,
                                                              // ),
                                                              Row(
                                                                children: <Widget>[

                                                                  Expanded(
                                                                    child: InkWell(
                                                                      onTap: ()
                                                                      {
                                                                        Navigator.of(context).pushReplacementNamed("/wallet");
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(10.0),
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(5.0),
                                                                              topRight: Radius.circular(5.0),
                                                                              bottomLeft: Radius.circular(5.0),
                                                                              bottomRight: Radius.circular(5.0),
                                                                            ),
                                                                            color: maincolor,
                                                                          ),
                                                                          padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                                                                          alignment: Alignment.center,
                                                                          child: Text("Ok",style: TextStyle(fontSize: textSizeMedium,color:Colors.white,fontWeight: FontWeight.w600),),
                                                                        ),
                                                                      ),
                                                                    ),

                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                              );
                                            }
                                            else if(res["status"] == "yes")
                                            {
                                              setState(() => _isProccessing = false);
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      Dialog(
                                                        backgroundColor: Colors.white,
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              Container(
                                                                padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment
                                                                      .center,
                                                                  children: <Widget>[
                                                                    Lottie.asset(
                                                                      'assets/order_confirm.json',
                                                                      repeat: true,
                                                                      reverse: false,
                                                                      animate: true,
                                                                      height: MediaQuery.of(context).size.height * 0.40,
                                                                    ),
                                                                    SizedBox(
                                                                      height: spacing_standard,
                                                                    ),
                                                                    Align(
                                                                        alignment: Alignment.center,
                                                                        child: Text(res['message'], style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold,color: maincolor),)
                                                                    ),
                                                                    SizedBox(
                                                                      height: spacing_middle,
                                                                    ),
                                                                    Align(
                                                                      alignment: Alignment.center,
                                                                      child: Text(
                                                                        res['description'],
                                                                        style: TextStyle(
                                                                            fontSize: textSizeMMedium,fontWeight: FontWeight.w500, letterSpacing: 0.2
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: spacing_standard,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              // Divider(
                                                              //   color: Colors.grey,
                                                              // ),
                                                              Row(
                                                                children: <Widget>[

                                                                  Expanded(
                                                                    child: InkWell(
                                                                      onTap: ()
                                                                      {
                                                                        Navigator.of(context).pushReplacementNamed("/bottomhome");
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(10.0),
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(5.0),
                                                                              topRight: Radius.circular(5.0),
                                                                              bottomLeft: Radius.circular(5.0),
                                                                              bottomRight: Radius.circular(5.0),
                                                                            ),
                                                                            color: maincolor,
                                                                          ),
                                                                          padding: EdgeInsets.fromLTRB(10, 12, 10, 12),
                                                                          alignment: Alignment.center,
                                                                          child: Text("Close",style: TextStyle(fontSize: textSizeMedium,color:Colors.white,fontWeight: FontWeight.w600),),
                                                                        ),
                                                                      ),
                                                                    ),

                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                              );
                                            }
                                            else {
                                              setState(() => _isProccessing = false);
                                            }
                                          });
                                        }
                                      }
                                    }
                                  }
                                  else
                                  {

                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10,0, 10, 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0),
                                        bottomLeft: Radius.circular(5.0),
                                        bottomRight: Radius.circular(5.0),
                                      ),
                                      color: maincolor,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 10),
                                    alignment: Alignment.center,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("UPDATE",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: textSizeMMedium,fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ):Container(),
                      ],
                    ),
                  ],
                ):Column(

                ),
              ],
            ):
            Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10,0, 10, 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed("/check");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0),
                            bottomLeft: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0),
                          ),
                          color: maincolor,
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10),
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("LOGIN NOW",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: textSizeMMedium,fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],),
          ],
        ),
      );
    }
  }


}