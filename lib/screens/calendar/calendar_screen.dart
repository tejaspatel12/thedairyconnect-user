import 'dart:async';
import 'dart:ui';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/models/calendar.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new CalendarScreenState();
  }
}

class CalendarScreenState extends State<CalendarScreen>{
  BuildContext _ctx;
  NetworkUtil _netUtil = new NetworkUtil();

  Future<List<CalendarList>> CalendarListdata;
  Future<List<CalendarList>> CalendarListfilterData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  // bool _isdataUser=false;
  bool _isLoadData=true;
  DateTime dateTime,date22;
  DateTime _selectedDate;
  String user_id;
  String time_slot,cutoff_time;
  String login;
  String newdate;
  // String time_slot,cutoff_time;

  var now;
  var later;

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    print("user_id" + user_id);
    setState(() {

      CalendarListdata = _getCalendarData();
      CalendarListfilterData=CalendarListdata;
    });
  }

  // _loadUserTime() async {
  //   prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     user_id = prefs.getString("user_id") ?? '';
  //     _netUtil.post(RestDatasource.GET_USER_DASHBOARD, body: {
  //       "user_id": user_id,
  //     }).then((dynamic res) async {
  //       setState(() {
  //         time_slot = res["time_slot"].toString();
  //         cutoff_time = res["cutoff_time"].toString();
  //         _isdataUser = false;
  //       });
  //     });
  //   });
  // }

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
          // date22 = DateFormat('yyyy-MM-dd H:mm:ss').format(_selectedDate).toString();
          // if(cutoff_time=="22:00:00")
          // {
          //   if(DateTime.parse(newdate.toString()).isBefore
          //     (DateTime.parse(_selectedDate.toString()))==false)
          //   {
          //     // date22 = (_selectedDate.add(Duration(days: 1)));
          //     date22 = DateFormat('yyyy-MM-dd H:mm:ss').format(_selectedDate.subtract(Duration(days : 1))).toString();
          //   }
          //   else
          //   {
          //     // date22.add(Duration(days: 2));
          //     // date22 = (_selectedDate.add(Duration(days: 2)));
          //     date22 = DateFormat('yyyy-MM-dd H:mm:ss').format(_selectedDate.add(Duration(days: 1))).toString();
          //   }
          // }

          // if(cutoff_time=="14:00:00")
          // {
          //   print("newdate : "+newdate);
          //   print("_selectedDate : "+DateFormat('yyyy-MM-dd H:mm:ss').format(_selectedDate).toString());
          //   if(DateTime.parse(newdate.toString()).isBefore
          //     (DateTime.parse(DateTime.now().toString()))==false)
          //   {
          //     // date22 = (_selectedDate.add(Duration(days : 1)));
          //     // print("First "+DateFormat('yyyy-MM-dd H:mm:ss').format(_selectedDate).toString());
          //     print("First");
          //   }
          //   else
          //   {
          //     // date22 = _selectedDate;
          //     // date22 = (_selectedDate.subtract(Duration(days : 1)));
          //     // print("Sec : "+DateFormat('yyyy-MM-dd H:mm:ss').format(_selectedDate).toString());
          //     print("Sec");
          //   }
          // }
          // newdate = DateFormat('yyyy-MM-dd H:mm:ss').format(newdate).toString();
          _isLoadData = false;
        });
      });
    });
  }

  //Load Data
  Future<List<CalendarList>> _getCalendarData() async
  {
    // print("Click");
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.CALENDAR,
        body:{
          'action' : "get_my_calendar",
          'user_id' : user_id,
          'date' : DateFormat('yyyy-MM-dd').format(_selectedDate).toString(),
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      print(items);
      List<CalendarList> listofusers = items.map<CalendarList>((json) {
        return CalendarList.fromJson(json);
      }).toList();
      List<CalendarList> revdata = listofusers.toList();

      return revdata;
    });
  }

  //On Refresh
  Future<List<CalendarList>> _refresh1() async
  {
    setState(() {
      CalendarListdata = _getCalendarData();
      CalendarListfilterData=CalendarListdata;
    });
  }

  TextEditingController dateCtl = TextEditingController();

  bool _isLoading = false;
  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    now =  DateTime.now();
    later = now.add(const Duration(seconds: 5));
    dateTime = DateTime.now();
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
    _resetSelectedDate();
    initializeDateFormatting();
    // _loadUserTime();
    _loadCutOff();
  }

  void _resetSelectedDate() {
    _selectedDate = DateTime.now();
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
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: shadecolor,
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
              child: AppBar(
                backgroundColor: maincolor,
                automaticallyImplyLeading: false, // hides leading widget
                flexibleSpace: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 40,
                    ),
                    CalendarTimeline(
                      showYears: true,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(Duration(days: 15)),
                      lastDate: DateTime.now().add(Duration(days: 15)),
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                          _loadCutOff();
                          // _refresh1();
                          _loadPref();
                        });
                      },
                      leftMargin: 20,
                      monthColor: whitecolor,
                      dayColor: whitecolor,
                      dayNameColor: maincolor,
                      activeDayColor: maincolor,
                      activeBackgroundDayColor: whitecolor,
                      dotsColor: maincolor,
                      // selectableDayPredicate: (date) => date.day != 23,
                      locale: 'en',
                    ),
                    // Text(DateFormat('h:mm:ss').format(_selectedDate).toString()+" "+cutoff_time.toString()),
                  ],
                ),
              )
          ),
          body: (_isLoadData) ?
            Center(
                child: Lottie.asset(
                'assets/loading.json',
                repeat: true,
                reverse: true,
                animate: true,
            )):Stack(
            children: <Widget>[
              RefreshIndicator(
                key: _refreshIndicatorKey,
                color: maincolor,
                onRefresh: _refresh1,
                child: FutureBuilder<List<CalendarList>>(
                  future: CalendarListdata,
                  builder: (context,snapshot) {
                    if ((snapshot).connectionState == ConnectionState.waiting)
                    {
                      return const Center(
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
                            const SizedBox(
                              height: 10,
                            ),
                            Text("No Order on "+DateFormat('yyyy-MM-dd').format(_selectedDate).toString()+"."),
                          ],
                        ),
                      );
                    }
                    return ListView(
                      padding: EdgeInsets.only(top: 5),
                      children: snapshot.data
                          .map((data) =>


                          // cutoff_time=="22:00:00"?
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child:
                            //new = cutoff
                            // date22 = current
                            DateTime.parse(dateTime.toString()).isBefore
                              (DateTime.parse(data.oc_cutoff_time.toString()))==true?
                            Container(
                              child:

                              InkWell(
                                onTap: ()
                                {
                                  Navigator.of(context).pushNamed("/calendardetail",
                                      arguments: {
                                        "order_id" : data.order_id,
                                        "product_name" : data.product_name,
                                        "date" : DateFormat('yyyy-MM-dd').format(_selectedDate).toString(),
                                      });
                                },
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 120, height: 120,)):ClipOval(child: new Image.asset('images/logo.png', width: 120, height: 120,)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            Text(data.product_name==null?"":data.product_name, style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

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
                                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                child: Text(data.order_qty==null?"":data.order_qty.toString()+ " Quantity", style: TextStyle(color: whitecolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                              ),
                                            ),
                                            SizedBox(
                                              height: spacing_control,
                                            ),

                                            data.oc_is_delivered=="1"?SizedBox():
                                            data.oc_is_delivered=="3"?
                                            Text("Order Cancel : Insufficient Balance".toUpperCase(), style: TextStyle(color: maincolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)):
                                            data.oc_is_delivered=="4"?
                                            Text("Order cancelled due to order value lower than £80".toUpperCase(), style: TextStyle(color: maincolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)):
                                            data.oc_is_delivered=="0"?Column(
                                              children: [
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
                                            ):SizedBox(),


                                            SizedBox(
                                              height: spacing_standard,
                                            ),

                                            data.oc_is_delivered=="1"?
                                            Text("delivered".toUpperCase(), style: TextStyle(color: maincolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)):
                                            SizedBox(),

                                            data.oc_is_delivered=="1"?Column(
                                              children: [
                                                SizedBox(
                                                  height: spacing_standard,
                                                ),
                                                Text(data.order_total_amt==null?"":"£"+data.order_total_amt, style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                                              ],
                                            ):
                                            SizedBox(),

                                            // SizedBox(
                                            //   height: spacing_middle,
                                            // ),
                                            // data.user_type=="1"?
                                            // Text(data.product_regular_price==null?"":rupeesimbol+data.product_regular_price.toString()+"/Unit", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)):
                                            // Text(data.product_normal_price==null?"":rupeesimbol+data.product_normal_price.toString()+"/Unit", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ):
                            Container(
                              child:

                              InkWell(
                                onTap: ()
                                {
                                  // FlashHelper.errorBar(context, message: "Click");
                                },
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 120, height: 120,)):ClipOval(child: new Image.asset('images/logo.png', width: 120, height: 120,)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              Text(data.product_name==null?"":data.product_name, style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                              SizedBox(
                                                height: spacing_standard,
                                              ),

                                              // time_slot=="Morning Beach"?Text("Morning Beach".toUpperCase(), style: TextStyle(color: maincolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)):
                                              // time_slot=="Evening Beach"?Text("Evening Beach".toUpperCase(), style: TextStyle(color: maincolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)):SizedBox(),
                                              // SizedBox(
                                              //   height: spacing_standard,
                                              // ),
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
                                                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                  child: Text(data.order_qty==null?"":data.order_qty.toString()+ " Quantity", style: TextStyle(color: whitecolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                                ),
                                              ),
                                              SizedBox(
                                                height: spacing_control,
                                              ),

                                              data.oc_is_delivered=="1" || data.oc_is_delivered=="2" ?SizedBox():
                                              data.oc_is_delivered=="3"?
                                              Text("Order Cancel : Insufficient Balance", style: TextStyle(color: redcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)):
                                              data.oc_is_delivered=="4"?
                                              Text("Order cancelled because order value is below £80", style: TextStyle(color: redcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)):
                                              data.oc_is_delivered=="5"?
                                              Text("Not delivered".toUpperCase(), style: TextStyle(color: redcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)):
                                              Column(
                                                children: [
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

                                              SizedBox(
                                                height: spacing_standard,
                                              ),


                                              data.oc_is_delivered=="1"?Text("delivered".toUpperCase(), style: TextStyle(color: maincolor,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)):
                                              SizedBox(),

                                              data.oc_is_delivered=="1"?Column(
                                                children: [
                                                  SizedBox(
                                                    height: spacing_standard,
                                                  ),
                                                  Text(data.order_total_amt==null?"":"£"+data.order_total_amt, style: TextStyle(color: titletext,fontSize: textSizeSmall, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                                                ],
                                              ):
                                              SizedBox(),

                                              // SizedBox(
                                              //   height: spacing_middle,
                                              // ),
                                              // data.user_type=="1"?
                                              // Text(data.product_regular_price==null?"":rupeesimbol+data.product_regular_price.toString()+"/Unit", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)):
                                              // Text(data.product_normal_price==null?"":rupeesimbol+data.product_normal_price.toString()+"/Unit", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),

                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
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
        ),
      );
    }
  }

}
