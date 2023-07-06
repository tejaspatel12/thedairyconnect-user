import 'dart:async';

import 'package:flutter_html/flutter_html.dart';
import 'package:dairy_connect/models/faq.dart';
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

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  BuildContext _ctx;
  bool _isdataLoading = true;

  String user_id="";

  NetworkUtil _netUtil = new NetworkUtil();
  Future<List<FAQList>> FAQListdata;
  Future<List<FAQList>> FAQListfilterData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    print("user_id" + user_id);
    setState(() {

      FAQListdata = _getPaymentData();
      FAQListfilterData=FAQListdata;
    });
  }

  //Load Data
  Future<List<FAQList>> _getPaymentData() async
  {
    // print("Click");
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.FAQ,
        body:{
          'action' : "show_faq",
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      // print(items);
      List<FAQList> listofusers = items.map<FAQList>((json) {
        return FAQList.fromJson(json);
      }).toList();
      List<FAQList> revdata = listofusers.toList();

      return revdata;
    });
  }

  //On Refresh
  Future<List<FAQList>> _refresh1() async
  {
    setState(() {
      FAQListdata = _getPaymentData();
      FAQListfilterData=FAQListdata;
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
          title: Text("FAQ".toUpperCase(),style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            RefreshIndicator(
              key: _refreshIndicatorKey,
              color: maincolor,
              onRefresh: _refresh1,
              child: FutureBuilder<List<FAQList>>(
                future: FAQListdata,
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text("Q : ", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                      Text(data.faq_question==null?"":data.faq_question, style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: spacing_middle,
                                  ),
                                  Row(
                                    children: [
                                      Text("A : ", style: TextStyle(color: blackcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                      Expanded(
                                        child: Html(
                                          data: data.faq_answer==null?"":data.faq_answer,
                                        ),
                                      ),
                                    ],
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
