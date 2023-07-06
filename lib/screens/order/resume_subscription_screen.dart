import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_svg/svg.dart';
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

class ResumeSubscriptionScreen extends StatefulWidget {
  @override
  _ResumeSubscriptionScreenState createState() => _ResumeSubscriptionScreenState();
}

class _ResumeSubscriptionScreenState extends State<ResumeSubscriptionScreen> {
  BuildContext _ctx;

  File _image = null;

  // final picker = ImagePicker();

  NetworkUtil _netUtil = new NetworkUtil();
  bool _isdataLoading = false;
  bool _isLoadData = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String order_id,user_id;
  String time_slot,cutoff_time;
  DateTime dateTime;
  DateTime mordate;
  String newdate;

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    print("user_id" + user_id);
  }

  _loadCutOff() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString("user_id") ?? '';
      _netUtil.post(RestDatasource.GET_USER_DASHBOARD, body: {
        "user_id": user_id,
      }).then((dynamic res) async {
        setState(() {
          time_slot = res["time_slot"].toString();
          cutoff_time = res["cutoff_time"].toString();
          newdate = DateFormat('yyyy-MM-dd').format(dateTime).toString();
          newdate = newdate+" "+ cutoff_time;
          // newdate = DateFormat('yyyy-MM-dd H:mm:ss').format(newdate).toString();

          if(cutoff_time=="22:00:00")
          {
            DateTime.parse(newdate.toString()).isBefore
              (DateTime.parse(dateTime.toString()))==false?
            mordate=dateTime.add(Duration(days: 1)):
            mordate=dateTime.add(Duration(days: 2));
          }
          else if(cutoff_time=="14:00:00")
          {
            DateTime.parse(newdate.toString()).isBefore
              (DateTime.parse(dateTime.toString()))==false?
            mordate=dateTime:
            mordate=dateTime.add(Duration(days: 1));
          }
          else{}

          _isLoadData = false;
        });
      });
    });
  }

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    super.initState();
    dateTime = DateTime.now();
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
    _loadCutOff();
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
    setState(() {
      _ctx = context;
      final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
      order_id = arguments['order_id'];
    });
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
                    title: Text(order_id==null?"":"Order id : ".toUpperCase()+order_id,
                      style: TextStyle(color: Colors.white),),
                    iconTheme: IconThemeData(color: Colors.white),

                    pinned: true,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                  ),
                ];
              },
              body: (_isLoadData) ? new Center(
                  child: Lottie.asset(
                    'assets/loading.json',
                    repeat: true,
                    reverse: true,
                    animate: true,
                  ))
                  : ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 10),
                children: <Widget>[


                  cutoff_time=="22:00:00"?
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        color: whitecolor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(0.0),
                                  bottomRight: Radius.circular(0.0),
                                ),
                                // color : maincolor,
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                child: Row(
                                  children: [
                                    Text("Pause Date", style: TextStyle(color: whitecolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
                                    // Text(DateFormat('d-MM-yyy').format(dateTime2), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                    Text(DateFormat('d-MM-yyy').format(mordate), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5))
                                  ],
                                ),

                                DateTime.parse(newdate.toString()).isBefore
                                  (DateTime.parse(dateTime.toString()))==false?
                                InkWell(
                                    onTap:() async {
                                      DateTime newDateTime = await showRoundedDatePicker(
                                        context: context,
                                        initialDate: dateTime.add(Duration(days: 1)),
                                        firstDate: dateTime.add(Duration(days: 1)),
                                        lastDate: DateTime(DateTime.now().year + 1),
                                        borderRadius: 2,
                                      );
                                      if (newDateTime != null) {
                                        setState(() => mordate = newDateTime);
                                      }
                                    },
                                    child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                )
                                    :InkWell(
                                    onTap:() async {
                                      DateTime newDateTime = await showRoundedDatePicker(
                                        context: context,
                                        initialDate: dateTime.add(Duration(days: 2)),
                                        firstDate: dateTime.add(Duration(days: 2)),
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
                            height: spacing_standard_new,
                          ),


                          SizedBox(
                            height: spacing_middle,
                          ),
                        ],
                      ),
                    ),
                  ):
                  cutoff_time=="14:00:00"?
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        color: whitecolor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(0.0),
                                  bottomRight: Radius.circular(0.0),
                                ),
                                // color : maincolor,
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                child: Row(
                                  children: [
                                    Text("Resume Date", style: TextStyle(color: whitecolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
                                    // Text(DateFormat('d-MM-yyy').format(dateTime2), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
                                        firstDate: dateTime,
                                        lastDate: DateTime(DateTime.now().year + 1),
                                        borderRadius: 2,
                                      );
                                      if (newDateTime != null) {
                                        setState(() => mordate = newDateTime);
                                      }
                                    },
                                    child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                ):InkWell(
                                    onTap:() async {
                                      DateTime newDateTime = await showRoundedDatePicker(
                                        context: context,
                                        initialDate: dateTime.add(Duration(days: 1)),
                                        firstDate: dateTime.add(Duration(days: 1)),
                                        lastDate: DateTime(DateTime.now().year + 1),
                                        borderRadius: 2,
                                      );
                                      if (newDateTime != null) {
                                        setState(() => mordate = newDateTime);
                                      }
                                    },
                                    child: Icon(Icons.edit,size:textSizeNormal,color: maincolor,)
                                )

                              ],
                            ),
                          ),
                          SizedBox(
                            height: spacing_standard_new,
                          ),


                          SizedBox(
                            height: spacing_middle,
                          ),
                        ],
                      ),
                    ),
                  ):SizedBox(),


                ],
              ),
            ),


            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[

                Container(
                  color: whitecolor,
                  child:  InkWell(
                    onTap: () {
                      NetworkUtil _netUtil = new NetworkUtil();
                      _netUtil.post(RestDatasource.ORDER, body: {
                        'action': "resumesubscription",
                        "user_id": user_id,
                        "order_id": order_id,
                        "resume_date": DateFormat('yyyy-MM-dd').format(mordate).toString(),
                      }).then((dynamic res) async {
                        if(res["status"] == "yes")
                        {
                          // FlashHelper.successBar(context, message: res['message']);
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
                                                    child: Text(res['message'], style: TextStyle(fontSize: textSizeXLarge,fontWeight: FontWeight.bold,color: maincolor),)
                                                ),
                                                SizedBox(
                                                  height: spacing_middle,
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "Your order has been Resume successfully",
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
                        else {
                          // FlashHelper.errorBar(context, message: res['message']);
                        }
                      });
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
                            Text("PUSH NOW",
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
            )
          ],
        ),
      );
    }
  }


}