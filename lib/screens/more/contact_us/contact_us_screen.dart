import 'dart:async';
import 'dart:io';
import 'dart:ui';
// import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/models/admin.dart';
import 'package:dairy_connect/models/user.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:flutter/material.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ContactUsScreenState();
  }
}

class ContactUsScreenState extends State<ContactUsScreen>{
  BuildContext _ctx;

  bool _isLoading = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String app_mobile1="", app_mobile2="",app_whatsapp="",app_gmail="",app_address="";
  String location="Coventry";

  NetworkUtil _netUtil = new NetworkUtil();

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
    // startTime();
    // _loadSetting();
  }

  _loadSetting() async {
    _netUtil.post(RestDatasource.APP_SETTING, body: {
      'action': "show_app_contact",
    }).then((dynamic res) async {
      print(res);
      setState(() {
        app_mobile1 = res[0]["app_mobile1"];
        app_mobile2 = res[0]["app_mobile2"];
        app_whatsapp = res[0]["app_whatsapp"];
        app_gmail = res[0]["app_gmail"];
        app_address = res[0]["app_address"];
        _isLoading = false;
      });
    });
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  openwhatsapp() async{
    var whatsapp = app_whatsapp;
    // var whatsappURl_android = "whatsapp://send?phone="+whatsapp+"&text=hello";
    var whatsappURl_android = "https://wa.me:/$whatsapp?text=hello";
    var whatappURL_ios ="https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if(Platform.isIOS){
      // for iOS phone only
      if( await canLaunch(whatappURL_ios)){
        await launch(whatappURL_ios, forceSafariVC: false);
      }else{
        // FlashHelper.errorBar(context, message: "Whatsapp Not Installed");
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: new Text("whatsapp no installed")));
      }
    }else{
      // android , web
      if( await canLaunch(whatsappURl_android)){
        await launch(whatsappURl_android);
      }
      // else if( await canLaunch(whatsappURl_android1)){
      //   await launch(whatsappURl_android1);
      // }
      else
      {
        // FlashHelper.errorBar(context, message: "Whatsapp Not Installed");
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: new Text("Whatsapp Not Installed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        drawer: DrawerNavigationBarController(),
        backgroundColor: shadecolor,
        appBar: AppBar(
          backgroundColor: maincolor,
          title: Text("Contact Us".toUpperCase(),style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body:
        // (_isLoading)
        //     ? new Center(
        //   child: Lottie.asset(
        //     'assets/loading.json',
        //     repeat: true,
        //     reverse: true,
        //     animate: true,
        //   ),
        //
        // ):
        ListView(
          padding: EdgeInsets.only(top: 5),
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(5.0),
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(5.0)),
                // color: whitecolor,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.05,
                  ),
                  Center(
                    child: Image.asset('images/logo.png',width: MediaQuery.of(context).size.width*0.25,),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.05,
                  ),
                  Text(apptitle.toUpperCase(), style: TextStyle(color: blackcolor,fontSize: textSizeLargeMedium, fontWeight: FontWeight.w700, letterSpacing: 0.5)),

                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.10,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: ()
                        {
                          setState(() {
                            location = "Coventry";
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0)),
                              color: location=="Coventry"?maincolor:whitecolor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Coventry".toUpperCase(), style: TextStyle(color: location=="Coventry"?whitecolor:maincolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            )
                        ),
                      ),

                      GestureDetector(
                        onTap: ()
                        {
                          setState(() {
                            location = "Birmingham";
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0)),
                              color: location=="Birmingham"?maincolor:whitecolor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Birmingham".toUpperCase(), style: TextStyle(color: location=="Birmingham"?whitecolor:maincolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            )
                        ),
                      ),

                      GestureDetector(
                        onTap: ()
                        {
                          setState(() {
                            location = "Warwick";
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(20.0)),
                              color: location=="Warwick"?maincolor:whitecolor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Warwick".toUpperCase(), style: TextStyle(color: location=="Warwick"?whitecolor:maincolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            )
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.07,
                  ),


                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0)),
                        color: whitecolor,
                        // gradient: LinearGradient(
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        //   colors:
                        //   [
                        //
                        //     Color(0xFF0E50F6).withOpacity(1),
                        //     Color(0xFF0E50F6).withOpacity(0.5),
                        //     // Color(0xFFFFFFFF).withOpacity(0.2),
                        //     // Color(0xFF0E50F6).withOpacity(0.3),
                        //   ],
                        //   stops: [0.1, 2],),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text("Mobile".toUpperCase(), style: TextStyle(color: blackcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            SizedBox(
                              height: spacing_standard,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(location=="Coventry"?"+44 7434089143":location=="Birmingham"?"+44 9662157867":location=="Warwick"?"+44 9825174243":"", style: TextStyle(color: maincolor,fontSize: textSizeNormal, fontWeight: FontWeight.w300, letterSpacing: 0.5)),
                              ],
                            ),

                            SizedBox(
                              height: spacing_middle,
                            ),

                            Text("Whatsapp".toUpperCase(), style: TextStyle(color: blackcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            SizedBox(
                              height: spacing_standard,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(location=="Coventry"?"+44 7434089143":location=="Birmingham"?"+44 9662157867":location=="Warwick"?"+44 9825174243":"", style: TextStyle(color: maincolor,fontSize: textSizeNormal, fontWeight: FontWeight.w300, letterSpacing: 0.5)),
                              ],
                            ),

                            SizedBox(
                              height: spacing_middle,
                            ),

                            Text("Mail".toUpperCase(), style: TextStyle(color: blackcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            SizedBox(
                              height: spacing_standard,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("dairyconnect@gmail.com", style: TextStyle(color: maincolor,fontSize: textSizeLargeMedium, fontWeight: FontWeight.w300, letterSpacing: 0.5)),
                              ],
                            ),

                            SizedBox(
                              height: spacing_standard_new,
                            ),

                            Text("Address".toUpperCase(), style: TextStyle(color: blackcolor,fontSize: textSizeSmall, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                            SizedBox(
                              height: spacing_standard_new,
                            ),
                            Text(
                                location=="Coventry"?
                                "West Orchards Shopping Centre, Coventry CV1 1QX":
                                location=="Birmingham"?
                                "NCP Car Park Birmingham High Street, Dale End, Birmingham B4 7LN":
                                location=="Warwick"?
                                "Picturesque 41 Smith St, Warwick CV34 4JA":""
                                , style: TextStyle(color: maincolor,fontSize: textSizeMedium, fontWeight: FontWeight.w300, letterSpacing: 0.5)),


                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),

      );
    }
  }

}
