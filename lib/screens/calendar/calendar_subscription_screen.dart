import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarSubscriptionScreen extends StatefulWidget {
  @override
  _CalendarSubscriptionScreenState createState() => _CalendarSubscriptionScreenState();
}

class _CalendarSubscriptionScreenState extends State<CalendarSubscriptionScreen> {
  BuildContext _ctx;


  // final picker = ImagePicker();

  NetworkUtil _netUtil = new NetworkUtil();
  bool _isdataLoading = true;
  bool _isLoadData = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String order_id,user_id,product_name,date;
  String oc_id,order_date,product_id,delivery_schedule,order_instructions,order_ring_bell,product_image,user_type,oc_is_delivered;
  double product_regular_price,product_normal_price;
  int num=0;
  int order_qty;
  DateTime dateTime;
  String time_slot,cutoff_time,newdate;

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    _netUtil.post(RestDatasource.CALENDAR, body: {
      'action': "get_calendar_detail",
      'order_id': order_id,
      'user_id': user_id,
      'date': date,
    }).then((dynamic res) async {
      print(res);
      setState(() {
        num = 1;
        oc_id = res[0]["oc_id"];
        order_id = res[0]["order_id"];
        user_id = res[0]["user_id"];
        order_qty = res[0]["order_qty"];
        order_date = res[0]["order_date"];
        // oc_cutoff_time = res[0]["oc_cutoff_time"];
        product_id = res[0]["product_id"];
        delivery_schedule = res[0]["delivery_schedule"];
        order_instructions = res[0]["order_instructions"];
        order_ring_bell = res[0]["order_ring_bell"];
        product_name = res[0]["product_name"];
        product_image = res[0]["product_image"];
        product_regular_price = res[0]["product_regular_price"].toDouble();
        product_normal_price = res[0]["product_normal_price"].toDouble();
        user_type = res[0]["user_type"];
        oc_is_delivered = res[0]["oc_is_delivered"];
        _isdataLoading = false;

      });
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
    dateTime = DateTime.now();
    super.initState();
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
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
      date = arguments['date'];
      product_name = arguments['product_name'];
      num == 0 ?
      _loadPref() : null;
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
                    title: Text(product_name==null?"":product_name,
                      style: TextStyle(color: Colors.white),),
                    iconTheme: IconThemeData(color: Colors.white),

                    pinned: true,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                  ),
                ];
              },
              body: (_isdataLoading)
                  ? new Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  repeat: true,
                  reverse: true,
                  animate: true,
                ),

              ):( _isLoadData)
                  ? new Center(
                child: Lottie.asset(
                  'assets/loading.json',
                  repeat: true,
                  reverse: true,
                  animate: true,
                ),

              )
                  : ListView(
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
                                            decoration: BoxDecoration(
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
                                                SizedBox(
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

                                                          SizedBox(
                                                            height: spacing_middle,
                                                          ),

                                                          // product_type=="1"?
                                                          Row(
                                                            children: [
                                                              user_type=="1"?
                                                              Text(product_regular_price==null?"":"£"+product_regular_price.toString()+"/Unit", style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)):
                                                              Text(product_normal_price==null?"":"£"+product_normal_price.toString()+"/Unit", style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)),

                                                            ],
                                                          ),

                                                          oc_is_delivered=="1"?
                                                          Column(
                                                            children: [
                                                              SizedBox(
                                                                height: spacing_standard,
                                                              ),
                                                              Text(order_qty==null?"":order_qty.toString()+" Quantity Delivered", style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)),
                                                            ],
                                                          ):SizedBox(),


                                                          SizedBox(
                                                            height: spacing_middle,
                                                          ),
                                                          Text("Produced by "+ apptitle, style: TextStyle(color: textcolor,fontSize: textSizeSmall, letterSpacing: 0.5)),
                                                        ],
                                                      ),


                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: spacing_middle,
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
                                                                Text(oc_is_delivered=="1"?"Delivered Date":"Delivery Date", style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
                                                                Text(date, style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                              ],
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

                                                // dateTime.isBefore(DateTime.parse(newdate.toString()))?
                                                Container(
                                                  child: oc_is_delivered=="1"?SizedBox():
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
                                                                  Text("Delivery Quantity", style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                                                ],
                                                              ),
                                                            )
                                                        ),
                                                        SizedBox(
                                                          height: spacing_middle,
                                                        ),


                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [

                                                            InkWell(
                                                              onTap: (){
                                                                setState(() {
                                                                  // int.parse(price);
                                                                  if(order_qty <= 1)
                                                                  {

                                                                  }
                                                                  else
                                                                  {
                                                                    order_qty = order_qty-1;
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
                                                              child: Text(order_qty.toString(),
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
                                                                  if(order_qty >= 10)
                                                                  {
                                                                  }
                                                                  else
                                                                  {
                                                                    order_qty = order_qty+1;
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
                                                            Text("Edit Quantity",
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
                                                ),

                                                SizedBox(
                                                  height: spacing_middle,
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
                                                                Text("Cancel Order For "+date, style: TextStyle(color: textcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
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
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            InkWell(
                                                              onTap: (){
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
                                                                                            'action': "cancel_calendar_order",
                                                                                            "user_id": user_id,
                                                                                            "order_id": order_id,
                                                                                            "time": date,
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
                                                                                                                        Navigator.of(context).pushReplacementNamed("/calendar");
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
                                                                  padding: EdgeInsets.fromLTRB(9  , 10, 9, 10),
                                                                  child: Text("Cancel Order".toUpperCase(), style: TextStyle(color: whitecolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0))
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: spacing_standard_new,
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






                                              ],)),
                                      ),

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

            oc_is_delivered=="1"?SizedBox():Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[

                Container(
                  color: whitecolor,
                  child:  InkWell(
                    onTap: () {

                      if (_isdataLoading == false) {

                          setState(() => _isdataLoading = true);

                          NetworkUtil _netUtil = new NetworkUtil();
                          _netUtil.post(RestDatasource.CALENDAR, body: {
                            'action': "update_calendar_subscription",
                            'oc_id': oc_id,
                            'user_id': user_id,
                            'date': date,
                            "order_qty": order_qty.toString(),
                            "order_one_unit_price": user_type=="1"?product_regular_price.toString():product_normal_price.toString(),
                          }).then((dynamic res) async {
                            if(res["status"] == "insufficient_balance")
                            {
                              setState(() => _isdataLoading = false);
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
                              setState(() => _isdataLoading = false);
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
                                                        child: Text(res['message'], style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold,color: maincolor),)
                                                    ),
                                                    SizedBox(
                                                      height: spacing_middle,
                                                    ),
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        "Your "+ date +" quantity has been Update successfully",
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
                                                        // Navigator.of(context).pushReplacementNamed("/bottomhome");
                                                        Navigator.of(context).pushReplacementNamed("/calendar");
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
                              setState(() => _isdataLoading = false);
                              // FlashHelper.errorBar(context, message: res['message']);
                            }
                          });

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
                            Text("UPDATE NOW",
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
            ),
          ],
        ),
      );
    }
  }


}