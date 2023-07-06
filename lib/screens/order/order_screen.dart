import 'dart:async';

import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/models/once_order.dart';
import 'package:dairy_connect/models/order.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  BuildContext _ctx;
  bool _isdataLoading = true;

  String user_id="";
  String login;
  DateTime StopdateTime;

  NetworkUtil _netUtil = new NetworkUtil();
  Future<List<OrderList>> OrderListdata;
  Future<List<OrderList>> OrderListfilterData;

  Future<List<OnceOrderList>> OnceOrderListdata;
  Future<List<OnceOrderList>> OnceOrderListfilterData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 = new GlobalKey<RefreshIndicatorState>();

  TabController _tabController;
  int _currentIndex = 0;
  bool _isLoadData = true;
  bool _isProccessing = false;
  String time_slot,cutoff_time,newdate;
  DateTime dateTime,mordate;

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    print("user_id" + user_id);
    setState(() {

      OrderListdata = _getPaymentData();
      OrderListfilterData=OrderListdata;

      OnceOrderListdata = _getOnceOrderData();
      OnceOrderListfilterData=OnceOrderListdata;
      _isdataLoading = false;
    });
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

  //Load Data
  Future<List<OrderList>> _getPaymentData() async
  {
    // print("Click");
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.ORDER,
        body:{
          'action' : "get_my_order",
          'user_id' : user_id,
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      print(items);
      List<OrderList> listofusers = items.map<OrderList>((json) {
        return OrderList.fromJson(json);
      }).toList();
      List<OrderList> revdata = listofusers.reversed.toList();

      return revdata;

    });
  }

  //On Refresh
  Future<List<OrderList>> _refresh1() async
  {
    setState(() {
      OrderListdata = _getPaymentData();
      OrderListfilterData=OrderListdata;
    });
  }

  //Load Data
  Future<List<OnceOrderList>> _getOnceOrderData() async
  {
    // print("Click");
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.ORDER,
        body:{
          'action' : "get_my_once_order",
          'user_id' : user_id,
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      print(items);
      List<OnceOrderList> listofusers = items.map<OnceOrderList>((json) {
        return OnceOrderList.fromJson(json);
      }).toList();
      List<OnceOrderList> revdata = listofusers.reversed.toList();

      return revdata;

    });
  }

  //On Refresh
  Future<List<OnceOrderList>> _refresh2() async
  {
    setState(() {
      OnceOrderListdata = _getOnceOrderData();
      OnceOrderListfilterData=OnceOrderListdata;
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
    dateTime = DateTime.now();
    StopdateTime = DateTime.now();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    _loadPref();
    _loadCutOff();
    navigationPage();
  }

  void _handleTabIndex() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  void navigationPage() async {
    var db = new DatabaseHelper();
    var isLoggedIn = await db.isLoggedIn();
    if(isLoggedIn) {
      setState(() {
        login="yes";
      });
    } else {
      setState(() {
        login = "no";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return
        login=="yes"?
        DefaultTabController(
        length: 2,
        child: new Scaffold(
          drawer: DrawerNavigationBarController(),
          backgroundColor: shadecolor,
          body: new NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  title: Text("My Order".toUpperCase()),
                  pinned: true,
                  floating: true,
                  centerTitle: true,
                  backgroundColor: maincolor,
                  forceElevated: innerBoxIsScrolled,
                  bottom: new TabBar(
                    indicatorColor: whitecolor,
                    controller: _tabController,
                    tabs: <Tab>[
                      new Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Subsciption",
                            style: TextStyle(
                                color: _tabController.index == 0
                                    ? whitecolor
                                    : whitecolor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      new Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "One Time",
                            style: TextStyle(
                                color: _tabController.index == 1
                                    ? whitecolor
                                    : whitecolor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: new TabBarView(
              controller: _tabController,
              children: <Widget>[
                (_isdataLoading)
                    ? new Center(
                  child: Lottie.asset(
                    'assets/loading.json',
                    repeat: true,
                    reverse: true,
                    animate: true,
                  ),

                ):
                (_isLoadData)
                    ? new Center(
                  child: Lottie.asset(
                    'assets/loading.json',
                    repeat: true,
                    reverse: true,
                    animate: true,
                  ),

                ):
                Stack(
                  children: <Widget>[
                    RefreshIndicator(
                      key: _refreshIndicatorKey,
                      color: maincolor,
                      onRefresh: _refresh1,
                      child: FutureBuilder<List<OrderList>>(
                        future: OrderListdata,
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
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 120, height: 120,)):ClipOval(child: new Image.asset('images/logo.png', width: 120, height: 120,)),
                                              SizedBox(
                                                width: spacing_standard,
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                // mainAxisAlignment: MainAxisAlignment.start,
                                                children: [

                                                  Text(data.product_name, style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                                  SizedBox(
                                                    height: spacing_standard,
                                                  ),

                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(5.0),
                                                        topRight: Radius.circular(5.0),
                                                        bottomLeft: Radius.circular(5.0),
                                                        bottomRight: Radius.circular(5.0),
                                                      ),
                                                      color: maincolor,
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                                      child: new Text(
                                                        data.delivery_schedule.toUpperCase(),
                                                        style: new TextStyle(
                                                          color: whitecolor,
                                                          fontSize: spacing_middle,
                                                        ),
                                                      ),
                                                    ),
                                                  ),


                                                  SizedBox(
                                                    height: spacing_standard,
                                                  ),

                                                  data.order_ring_bell=="1"?Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(5.0),
                                                        topRight: Radius.circular(5.0),
                                                        bottomLeft: Radius.circular(5.0),
                                                        bottomRight: Radius.circular(5.0),
                                                      ),
                                                      color: shadecolor, //
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                      child: Icon(Icons.notifications,size:textSizeLargeMedium,color: maincolor,),
                                                    ),
                                                  ):Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(5.0),
                                                        topRight: Radius.circular(5.0),
                                                        bottomLeft: Radius.circular(5.0),
                                                        bottomRight: Radius.circular(5.0),
                                                      ),
                                                      color: shadecolor, //
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                      child: Icon(Icons.notifications_off,size:textSizeLargeMedium,color:redcolor,),
                                                    ),
                                                  ),

                                                ],
                                              ),


                                            ],
                                          ),
                                          SizedBox(
                                            height: spacing_standard,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                                bottomLeft: Radius.circular(10.0),
                                                bottomRight: Radius.circular(10.0),
                                              ),
                                              color: shadecolor,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Row(
                                                    children: [
                                                      data.delivery_schedule=="Customize"?
                                                      Wrap(
                                                        children: [
                                                          data.ds_Sun!="0"?
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(5.0),
                                                                topRight: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0),
                                                              ),
                                                              // color: maincolor,
                                                              gradient: LinearGradient(
                                                                  begin: Alignment.topCenter,
                                                                  end: Alignment.bottomCenter,
                                                                  colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: Column(
                                                                children: [
                                                                  new Text(
                                                                    "Sun",
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    data.ds_Sun,
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ):Container(),
                                                          SizedBox(
                                                            width: spacing_control_half,
                                                          ),
                                                          data.ds_Mon!="0"?
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(5.0),
                                                                topRight: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0),
                                                              ),
                                                              // color: maincolor,
                                                              gradient: LinearGradient(
                                                                  begin: Alignment.topCenter,
                                                                  end: Alignment.bottomCenter,
                                                                  colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                                                            ),

                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: Column(
                                                                children: [
                                                                  new Text(
                                                                    "Mon",
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                  new Text(
                                                                    data.ds_Mon,
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ):Container(),
                                                          SizedBox(
                                                            width: spacing_control_half,
                                                          ),
                                                          data.ds_Tue!="0"?
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(5.0),
                                                                topRight: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0),
                                                              ),
                                                              // color: maincolor,
                                                              gradient: LinearGradient(
                                                                  begin: Alignment.topCenter,
                                                                  end: Alignment.bottomCenter,
                                                                  colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: Column(
                                                                children: [
                                                                  new Text(
                                                                    "Tue",
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                  new Text(
                                                                    data.ds_Tue,
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ):Container(),
                                                          SizedBox(
                                                            width: spacing_control_half,
                                                          ),
                                                          data.ds_Wed!="0"?
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(5.0),
                                                                topRight: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0),
                                                              ),
                                                              // color: maincolor,
                                                              gradient: LinearGradient(
                                                                  begin: Alignment.topCenter,
                                                                  end: Alignment.bottomCenter,
                                                                  colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: Column(
                                                                children: [
                                                                  new Text(
                                                                    "Wed",
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                  new Text(
                                                                    data.ds_Wed,
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ):Container(),
                                                          SizedBox(
                                                            width: spacing_control_half,
                                                          ),
                                                          data.ds_Thu!="0"?
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(5.0),
                                                                topRight: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0),
                                                              ),
                                                              // color: maincolor,
                                                              gradient: LinearGradient(
                                                                  begin: Alignment.topCenter,
                                                                  end: Alignment.bottomCenter,
                                                                  colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: Column(
                                                                children: [
                                                                  new Text(
                                                                    "Thu",
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                  new Text(
                                                                    data.ds_Thu,
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ):Container(),
                                                          SizedBox(
                                                            width: spacing_control_half,
                                                          ),
                                                          data.ds_Fri!="0"?
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(5.0),
                                                                topRight: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0),
                                                              ),
                                                              // color: maincolor,
                                                              gradient: LinearGradient(
                                                                  begin: Alignment.topCenter,
                                                                  end: Alignment.bottomCenter,
                                                                  colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: Column(
                                                                children: [
                                                                  new Text(
                                                                    "Fri",
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                  new Text(
                                                                    data.ds_Fri,
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ):Container(),
                                                          SizedBox(
                                                            width: spacing_control_half,
                                                          ),
                                                          data.ds_Sat!="0"?
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(5.0),
                                                                topRight: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0),
                                                              ),
                                                              // color: maincolor,
                                                              gradient: LinearGradient(
                                                                  begin: Alignment.topCenter,
                                                                  end: Alignment.bottomCenter,
                                                                  colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                              child: Column(
                                                                children: [
                                                                  new Text(
                                                                    "Sat",
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                  new Text(
                                                                    data.ds_Sat,
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: spacing_middle,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ):Container(),
                                                          SizedBox(
                                                            width: spacing_control_half,
                                                          ),
                                                        ],
                                                      ):data.delivery_schedule=="Alternate Day"?
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(5.0),
                                                            topRight: Radius.circular(5.0),
                                                            bottomLeft: Radius.circular(5.0),
                                                            bottomRight: Radius.circular(5.0),
                                                          ),
                                                          // color: maincolor,
                                                          gradient: LinearGradient(
                                                              begin: Alignment.topCenter,
                                                              end: Alignment.bottomCenter,
                                                              colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                          child: Column(
                                                            children: [
                                                              new Text(
                                                                data.ds_alt_diff,
                                                                style: new TextStyle(
                                                                  color: whitecolor,
                                                                  fontSize: spacing_middle,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: spacing_control,
                                                              ),
                                                              Text(
                                                                data.ds_qty,
                                                                style: new TextStyle(
                                                                  color: whitecolor,
                                                                  fontSize: spacing_middle,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ):
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(5.0),
                                                            topRight: Radius.circular(5.0),
                                                            bottomLeft: Radius.circular(5.0),
                                                            bottomRight: Radius.circular(5.0),
                                                          ),
                                                          gradient: LinearGradient(
                                                              begin: Alignment.topCenter,
                                                              end: Alignment.bottomCenter,
                                                              colors: [Color(0xFF51BB94), Color(0xFF2C8162)]),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                          child: Column(
                                                            children: [
                                                              new Text(
                                                                data.delivery_schedule,
                                                                style: new TextStyle(
                                                                  color: whitecolor,
                                                                  fontSize: spacing_middle,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: spacing_control,
                                                              ),
                                                              Text(
                                                                data.ds_qty,
                                                                style: new TextStyle(
                                                                  color: whitecolor,
                                                                  fontSize: spacing_middle,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: spacing_standard,
                                                  ),
                                                  // Text(DateFormat('d-MM-yyy').format(mordate), style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      data.order_subscription_status=="1"?
                                                      InkWell(
                                                        onTap:(){
                                                          Navigator.of(context).pushNamed("/pushsubscription",
                                                              arguments: {
                                                                "order_id" : data.order_id,
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
                                                            color: redcolor,
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.fromLTRB(8, 9, 8, 9),
                                                            child: new Text(
                                                              "Pause subscription".toUpperCase(),
                                                              style: new TextStyle(
                                                                color: whitecolor,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ):InkWell(
                                                        onTap:(){
                                                          if(data.delivery_schedule=="Everyday")
                                                          {
                                                              if (_isProccessing == false) {
                                                                  setState(() => _isProccessing = true);
                                                                  NetworkUtil _netUtil = new NetworkUtil();
                                                                  _netUtil.post(RestDatasource.RESUME_ORDER, body: {
                                                                    'action': "resume_order_everyday_subscription_product",
                                                                    "user_id": user_id,
                                                                    "order_id": data.order_id,
                                                                    "product_id": data.product_id,
                                                                    "product_name": data.product_name,
                                                                    "cutoff_time": cutoff_time,
                                                                    // "product_price": user_type=="1"?product_regular_price.toString():product_normal_price.toString(),
                                                                    "qty": data.ds_qty.toString(),
                                                                    "start_date": DateFormat('yyyy-MM-dd').format(mordate).toString(),
                                                                  }).then((dynamic res) async {
                                                                    if(res["status"] == "yes")
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
                                                          else if(data.delivery_schedule=="Alternate Day")
                                                          {
                                                            if (_isProccessing == false) {
                                                              setState(() => _isProccessing = true);
                                                              NetworkUtil _netUtil = new NetworkUtil();
                                                              _netUtil.post(RestDatasource.RESUME_ORDER, body: {
                                                                'action': "resume_order_alternateday_subscription_product",
                                                                "user_id": user_id,
                                                                "order_id": data.order_id,
                                                                "product_id": data.product_id,
                                                                "product_name": data.product_name,
                                                                "cutoff_time": cutoff_time,
                                                                "delivery_schedule": "Alternate Day",
                                                                "ds_alt_diff": data.ds_alt_diff,
                                                                "qty": data.ds_qty.toString(),
                                                                "start_date": DateFormat('yyyy-MM-dd').format(mordate).toString(),
                                                              }).then((dynamic res) async {
                                                                if(res["status"] == "yes")
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
                                                          else if(data.delivery_schedule=="Customize")
                                                          {
                                                            if (_isProccessing == false) {
                                                                setState(() => _isProccessing = true);
                                                                NetworkUtil _netUtil = new NetworkUtil();
                                                                _netUtil.post(RestDatasource.RESUME_ORDER, body: {
                                                                  'action': "resume_order_customize_subscription_product",
                                                                  "user_id": user_id,
                                                                  "product_id": data.product_id,
                                                                  "order_id": data.order_id,
                                                                  "product_name": data.product_name,
                                                                  "cutoff_time": cutoff_time,
                                                                  "delivery_schedule": "Customize",
                                                                  "ds_Sun": data.ds_Sun.toString(),
                                                                  "ds_Mon": data.ds_Mon.toString(),
                                                                  "ds_Tue": data.ds_Tue.toString(),
                                                                  "ds_Wed": data.ds_Wed.toString(),
                                                                  "ds_Thu": data.ds_Thu.toString(),
                                                                  "ds_Fri": data.ds_Fri.toString(),
                                                                  "ds_Sat": data.ds_Sat.toString(),
                                                                  "start_date": DateFormat('yyyy-MM-dd').format(mordate).toString(),
                                                                }).then((dynamic res) async {
                                                                  if(res["status"] == "yes")
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
                                                          else
                                                          {

                                                          }
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
                                                          child: Padding(
                                                            padding: EdgeInsets.fromLTRB(8, 9, 8, 9),
                                                            child: new Text(
                                                              "resume subscription".toUpperCase(),
                                                              style: new TextStyle(
                                                                color: whitecolor,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      //       :
                                                      // InkWell(
                                                      //   onTap:(){
                                                      //
                                                      //   },
                                                      //   child: Container(
                                                      //     decoration: BoxDecoration(
                                                      //       borderRadius: BorderRadius.only(
                                                      //         topLeft: Radius.circular(5.0),
                                                      //         topRight: Radius.circular(5.0),
                                                      //         bottomLeft: Radius.circular(5.0),
                                                      //         bottomRight: Radius.circular(5.0),
                                                      //       ),
                                                      //       color: maincolor,
                                                      //     ),
                                                      //     child: Padding(
                                                      //       padding: EdgeInsets.fromLTRB(8, 9, 8, 9),
                                                      //       child: new Text(
                                                      //         "resume at ".toUpperCase()+data.resume_date,
                                                      //         style: new TextStyle(
                                                      //           color: whitecolor,
                                                      //           fontSize: 12,
                                                      //         ),
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // ),

                                                      InkWell(
                                                        onTap:()
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
                                                                                    child: Text("End Subscription", style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold,color: maincolor),)
                                                                                ),
                                                                                SizedBox(
                                                                                  height: spacing_middle,
                                                                                ),
                                                                                Align(
                                                                                  alignment: Alignment.center,
                                                                                  child: Text(
                                                                                    "Do you want to End Subscription",
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
                                                                                      child: Text("No",style: TextStyle(fontSize: textSizeMedium,color:Colors.white,fontWeight: FontWeight.w600),),
                                                                                    ),
                                                                                  ),
                                                                                ),

                                                                              ),
                                                                              SizedBox(
                                                                                width: spacing_control,
                                                                              ),
                                                                              Expanded(
                                                                                child: InkWell(
                                                                                  onTap: ()
                                                                                  {
                                                                                    NetworkUtil _netUtil = new NetworkUtil();
                                                                                    _netUtil.post(RestDatasource.ORDER, body: {
                                                                                      'action': "stopsubscription",
                                                                                      "user_id": user_id,
                                                                                      "order_id": data.order_id,
                                                                                      "time": DateFormat('yyyy-MM-dd').format(StopdateTime).toString(),
                                                                                    }).then((dynamic res) async {
                                                                                      if(res["status"] == "yes")
                                                                                      {
                                                                                        // FlashHelper.successBar(context, message: res['message']);

                                                                                        Navigator.pop(context);
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
                                                                                                                  "Subscription has been stopped successfully. Hope to see you soon",
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
                                                                                        // FlashHelper.errorBar(context, message: res['message']);
                                                                                        Navigator.pop(context);
                                                                                      }
                                                                                    });

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
                                                                                      child: Text("Yes",style: TextStyle(fontSize: textSizeMedium,color:Colors.white,fontWeight: FontWeight.w600),),
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
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(5.0),
                                                              topRight: Radius.circular(5.0),
                                                              bottomLeft: Radius.circular(5.0),
                                                              bottomRight: Radius.circular(5.0),
                                                            ),
                                                            color: redcolor, //
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.fromLTRB(8, 9, 8, 9),
                                                            child: Text("End Subscription".toUpperCase(), style: TextStyle(color: whitecolor,fontSize: 10, letterSpacing: 0.1)),
                                                          ),
                                                        ),
                                                      ),

                                                      InkWell(
                                                        onTap: ()
                                                        {
                                                          Navigator.of(context).pushNamed("/productsubscription",
                                                              arguments: {
                                                                "product_id" : data.product_id,
                                                                "product_name" : data.product_name,
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
                                                            padding: EdgeInsets.fromLTRB(10, 9, 10, 9),
                                                            child: Text("edit".toUpperCase(), style: TextStyle(color: whitecolor,fontSize: 10, letterSpacing: 0.1)),
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),

                                                ],
                                              ),
                                            ),
                                          ),
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
                Stack(
                  children: <Widget>[
                    RefreshIndicator(
                      key: _refreshIndicatorKey2,
                      color: maincolor,
                      onRefresh: _refresh2,
                      child: FutureBuilder<List<OnceOrderList>>(
                        future: OnceOrderListdata,
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
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 120, height: 120,)):ClipOval(child: new Image.asset('images/logo.png', width: 120, height: 120,)),
                                              SizedBox(
                                                width: spacing_standard,
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Text(data.product_name, style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                                  SizedBox(
                                                    height: spacing_standard,
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(5.0),
                                                        topRight: Radius.circular(5.0),
                                                        bottomLeft: Radius.circular(5.0),
                                                        bottomRight: Radius.circular(5.0),
                                                      ),
                                                      color: maincolor,
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                                                      child: new Text(
                                                        data.start_date,
                                                        style: new TextStyle(
                                                          color: whitecolor,
                                                          fontSize: spacing_middle,
                                                        ),
                                                      ),
                                                    ),
                                                  ),


                                                  SizedBox(
                                                    height: spacing_standard,
                                                  ),

                                                  data.order_ring_bell=="1"?Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(5.0),
                                                        topRight: Radius.circular(5.0),
                                                        bottomLeft: Radius.circular(5.0),
                                                        bottomRight: Radius.circular(5.0),
                                                      ),
                                                      color: shadecolor, //
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                      child: Icon(Icons.notifications,size:textSizeLargeMedium,color: maincolor,),
                                                    ),
                                                  ):Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(5.0),
                                                        topRight: Radius.circular(5.0),
                                                        bottomLeft: Radius.circular(5.0),
                                                        bottomRight: Radius.circular(5.0),
                                                      ),
                                                      color: shadecolor, //
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                                                      child: Icon(Icons.notifications_off,size:textSizeLargeMedium,color:redcolor,),
                                                    ),
                                                  ),

                                                ],
                                              ),


                                            ],
                                          ),
                                          SizedBox(
                                            height: spacing_standard,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                                bottomLeft: Radius.circular(10.0),
                                                bottomRight: Radius.circular(10.0),
                                              ),
                                              color: shadecolor,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      InkWell(
                                                        onTap:()
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
                                                                                    child: Text("Cancle Order", style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold,color: maincolor),)
                                                                                ),
                                                                                SizedBox(
                                                                                  height: spacing_middle,
                                                                                ),
                                                                                Align(
                                                                                  alignment: Alignment.center,
                                                                                  child: Text(
                                                                                    "Do you want to cancle order",
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
                                                                                      child: Text("No",style: TextStyle(fontSize: textSizeMedium,color:Colors.white,fontWeight: FontWeight.w600),),
                                                                                    ),
                                                                                  ),
                                                                                ),

                                                                              ),
                                                                              SizedBox(
                                                                                width: spacing_control,
                                                                              ),
                                                                              Expanded(
                                                                                child: InkWell(
                                                                                  onTap: ()
                                                                                  {
                                                                                    NetworkUtil _netUtil = new NetworkUtil();
                                                                                    _netUtil.post(RestDatasource.ORDER, body: {
                                                                                      'action': "cancelorder",
                                                                                      "user_id": user_id,
                                                                                      "order_id": data.order_id,
                                                                                      "time": DateFormat('yyyy-MM-dd').format(StopdateTime).toString(),
                                                                                    }).then((dynamic res) async {
                                                                                      if(res["status"] == "yes")
                                                                                      {

                                                                                        Navigator.pop(context);
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
                                                                                                                  "Order has been cancle successfully. Hope to see you soon",
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
                                                                                        Navigator.pop(context);
                                                                                      }
                                                                                    });

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
                                                                                      child: Text("Yes",style: TextStyle(fontSize: textSizeMedium,color:Colors.white,fontWeight: FontWeight.w600),),
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
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(5.0),
                                                              topRight: Radius.circular(5.0),
                                                              bottomLeft: Radius.circular(5.0),
                                                              bottomRight: Radius.circular(5.0),
                                                            ),
                                                            color: redcolor, //
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.fromLTRB(8, 9, 8, 9),
                                                            child: Text("cancel order".toUpperCase(), style: TextStyle(color: whitecolor,fontSize: 12, letterSpacing: 0.1)),
                                                          ),
                                                        ),
                                                      ),

                                                    ],
                                                  ),

                                                ],
                                              ),
                                            ),
                                          ),
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
              ],
            ),
          ),
        ),
      ):
        SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            backgroundColor: shadecolor,
            body: ListView(
              padding: EdgeInsets.only(top: 0),
              children: [



                Padding(
                  padding: const EdgeInsets.fromLTRB(10,50, 10, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Html(
                      //   data: web_privacy_policy==null?"":web_privacy_policy,
                      // ),
                      //WEBSITE
                      Center(
                        child: Image.asset(
                          'images/logo.png',
                          // width: MediaQuery.of(context).size.width * 10,
                          width: 100,
                          height: MediaQuery.of(context).size.height * 0.15,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.03,
                      ),
                      Center(child: Text("Login Require", style: TextStyle(color: blackcolor,fontSize: textSizeLargeMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5))),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.04,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0)),
                            color: whitecolor,
                            boxShadow: [new BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3.0,
                            ),]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(13),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Text("Please login to View your order"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //WEBSITE

                      SizedBox(
                        height: spacing_middle,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5,10, 5, 10),
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
                                    padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                    alignment: Alignment.center,
                                    child: Text("Login Now".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: spacing_middle,
                      ),


                    ],
                  ),
                ),



              ],
            ),
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
