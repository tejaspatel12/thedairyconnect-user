import 'dart:async';

import 'package:dairy_connect/models/notification.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  BuildContext _ctx;
  bool _isdataLoading = true;

  String user_id="";

  NetworkUtil _netUtil = new NetworkUtil();
  Future<List<NotificationList>> NotificationListdata;
  Future<List<NotificationList>> NotificationListfilterData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    print("user_id" + user_id);
    setState(() {

      NotificationListdata = _getPaymentData();
      NotificationListfilterData=NotificationListdata;
    });
  }

  //Load Data
  Future<List<NotificationList>> _getPaymentData() async
  {
    // print("Click");
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.NOTIFICATION,
        body:{
          'action' : "user_notification",
          'user_id' : user_id,
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      // print(items);
      List<NotificationList> listofusers = items.map<NotificationList>((json) {
        return NotificationList.fromJson(json);
      }).toList();
      List<NotificationList> revdata = listofusers.reversed.toList();

      return revdata;
    });
  }

  //On Refresh
  Future<List<NotificationList>> _refresh1() async
  {
    setState(() {
      NotificationListdata = _getPaymentData();
      NotificationListfilterData=NotificationListdata;
    });
  }

  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _otpcode;


  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  @override
  Widget build(BuildContext context) {
    // _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        drawer: DrawerNavigationBarController(),
        backgroundColor: shadecolor,
        appBar: AppBar(
          backgroundColor: maincolor,
          title: Text("My Notification".toUpperCase(),style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            RefreshIndicator(
              key: _refreshIndicatorKey,
              color: maincolor,
              onRefresh: _refresh1,
              child: FutureBuilder<List<NotificationList>>(
                future: NotificationListdata,
                builder: (context,snapshot) {
                  if ((snapshot).connectionState == ConnectionState.waiting)
                  {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else if (!snapshot.hasData) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/opps.json',
                            repeat: true,
                            reverse: true,
                            animate: true,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text("No Data Available!"),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    padding: EdgeInsets.only(top: 5),
                    children: snapshot.data
                        .map((data) =>

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

                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(data.notification_title==null?"":data.notification_title, style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                  SizedBox(
                                    height: spacing_middle,
                                  ),
                                  Text(data.notification_des==null?"":data.notification_des, style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

                                ],
                              ),
                            ),
                          ),
                        ),


                    ).toList(),
                  );
                },
              ),
            )
          ],
        ),
      );
    }
  }
}



BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    border: Border.all(
        width: 1, //
        color: Colors.grey[400] //                  <--- border width here
    ),
  );
}
