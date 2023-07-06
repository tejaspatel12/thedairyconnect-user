import 'dart:async';

import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';

class TermsConditionScreen extends StatefulWidget {
  @override
  _TermsConditionScreenState createState() => _TermsConditionScreenState();
}


class _TermsConditionScreenState extends State<TermsConditionScreen> {
  BuildContext _ctx;
  int counter = 0;
  int _current = 0;
  String app_terms_condition;
  // Map<String, double> dataMap = Map();

  bool _isdataLoad = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  SharedPreferences prefs;
  NetworkUtil _netUtil = new NetworkUtil();

  _loadPref() async {
    prefs = await SharedPreferences.getInstance();

  }

  _loadWeb() async {
    _netUtil.post(RestDatasource.APP_SETTING, body: {
      'action' : "show_application_terms_condition",
      'app_id' : "1",
    }).then((dynamic res) async {
      print(res);
      setState(() {
        print(res);
        app_terms_condition=res[0]["app_terms_condition"];

        _isdataLoad=false;
      });
    });
  }

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
    _loadWeb();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: statusbarcolor,
          statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      backgroundColor: shadecolor,
      // backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: new Text("Terms and Condition",style: TextStyle(color: Colors.white),),
        // title: Image.asset('images/logo.png', fit: BoxFit.cover),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: maincolor,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(
        //     bottom: Radius.circular(20),
        //   ),
        // ),

      ),
      body: (_isdataLoad)?Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/loading.json',
            repeat: true,
            reverse: true,
            animate: true,
          ),
          SizedBox(
            height: 10,
          ),
          Text("Just Minute..."),
        ],
      ):
      ListView(
        padding: EdgeInsets.only(top: 0),
        children: [



          Padding(
            padding: const EdgeInsets.fromLTRB(10,10, 10, 4),
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
                          child: Html(
                            data: app_terms_condition==null?"":app_terms_condition,
                          ),
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
                              Navigator.pop(context);
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
                              child: Text("OK".toUpperCase(),style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
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


    );
  }
}
