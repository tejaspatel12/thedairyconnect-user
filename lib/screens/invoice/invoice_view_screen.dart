import 'dart:async';
import 'dart:io';
// import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InvoiceViewScreen extends StatefulWidget {
  @override
  _InvoiceViewScreenState createState() => _InvoiceViewScreenState();
}

class _InvoiceViewScreenState extends State<InvoiceViewScreen> {
  BuildContext _ctx;
  String user_id,invoice;
  bool _isLoadData = false;
  bool _isLoading = false;
  // PDFDocument document;


  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;

  @override
  initState() {
    super.initState();
    super.initState();
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    // if (Platform.isAndroid) WebView.platform = AndroidWebView();
    // loadDocument();
  }

  // loadDocument() async {
  //   // invoice
  //   // document = await PDFDocument.fromURL(
  //   //   "https://girorganic-admin.in/invoice/user_app.php?invoice=1",
  //   //   /* cacheManager: CacheManager(
  //   //       Config(
  //   //         "customCacheKey",
  //   //         stalePeriod: const Duration(days: 2),
  //   //         maxNrOfCacheObjects: 10,
  //   //       ),
  //   //     ), */
  //   // );
  //
  //   setState(() => _isLoadData = false);
  // }

  _launchURL() async {

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
      invoice = arguments['invoice'];
      print("invoice : "+invoice);
      invoice==null?null:_launchURL();
    });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        backgroundColor: shadecolor,
        body: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (BuildContext context,
                  bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    centerTitle: true,
                    backgroundColor: maincolor,
                    title: Text("Invoice".toUpperCase(),
                      style: TextStyle(color: Colors.white),),
                    iconTheme: IconThemeData(color: Colors.white),

                    pinned: true,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                  ),
                ];
              },
              body: (invoice==null) ? new Center(
                  child: Lottie.asset(
                    'assets/loading.json',
                    repeat: true,
                    reverse: true,
                    animate: true,
                  ))
                  :
              WebView(
                initialUrl: 'https://girorganic-admin.in/invoice/user_app.php?invoice='+invoice,
              ),

              // Html(
              //     data: 'https://girorganic-admin.in/invoice/user_app.php?invoice=1',
              //     style: {
              //       // text that renders h1 elements will be red
              //       // "p": Style(color: textcolor,fontSize: FontSize.smaller, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              //     }
              // ),


              // PDFViewer(
              //   document: document,
              //   zoomSteps: 1,
              // ),
            ),

          ],
        ),
      );
    }
  }


}