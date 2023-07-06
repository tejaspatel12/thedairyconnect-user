import 'dart:async';
import 'dart:math';

import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:dairy_connect/data/database_helper.dart';
import 'package:dairy_connect/models/payment.dart';
import 'package:dairy_connect/models/rechargeoffer.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RechargeOfferScreen extends StatefulWidget {
  @override
  _RechargeOfferScreenState createState() => _RechargeOfferScreenState();
}

class _RechargeOfferScreenState extends State<RechargeOfferScreen> {
  BuildContext _ctx;
  bool _isdataLoading = true;

  String user_id="",amt,_amt;
  String user_mobile_number,user_email;
  String login,order_id,keyId,keySecret;
  int securecode;


  Razorpay _razorpay;

  NetworkUtil _netUtil = new NetworkUtil();
  Future<List<RechargeOfferList>> RechargeOfferListdata;
  Future<List<RechargeOfferList>> RechargeOfferListfilterData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  SharedPreferences prefs;
  _loadPref() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    print("user_id" + user_id);
    setState(() {

      RechargeOfferListdata = _getRechargeOfferData();
      RechargeOfferListfilterData=RechargeOfferListdata;
    });
  }

  _loadUser() async {
    prefs = await SharedPreferences.getInstance();
    user_id= prefs.getString("user_id") ?? '';
    _netUtil.post(RestDatasource.USER, body: {
      'action': "get_user",
      'user_id': user_id,
    }).then((dynamic res) async {
      print(res);
      setState(() {
        user_mobile_number = res[0]["user_mobile_number"];
        user_email = res[0]["user_email"];
        _isdataLoading = false;

      });
    });
  }

  //Load Data
  Future<List<RechargeOfferList>> _getRechargeOfferData() async
  {
    // print("Click");
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.RECHARGE_OFFER,
        body:{
          'action' : "recharge_offer",
          'user_id': user_id,
        }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      // print(items);
      List<RechargeOfferList> listofusers = items.map<RechargeOfferList>((json) {
        return RechargeOfferList.fromJson(json);
      }).toList();
      List<RechargeOfferList> revdata = listofusers.reversed.toList();

      return revdata;
    });
  }

  //On Refresh
  Future<List<RechargeOfferList>> _refresh1() async
  {
    setState(() {
      RechargeOfferListdata = _getRechargeOfferData();
      RechargeOfferListfilterData=RechargeOfferListdata;
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
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print("setstate called");
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
    _loadUser();
    navigationPage();
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': keyId,
      'amount': amt + "00",
      'name': 'Dairy Connect',
      'order_id': order_id,
      'description': 'Payment',
      'prefill': {'contact': user_mobile_number, 'email': user_email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Fluttertoast.showToast(
    //   msg: "SUCCESS: " + response.paymentId,);
    _netUtil.post(
        RestDatasource.PAYMENT, body: {
      "action": "paymentdone",
      "user_id": user_id,
      "razorpay_payment_id": response.paymentId,
      "payment_amt": _amt,
      "payment_type": "Online",
      "payment_status": "1",
    }).then((dynamic res) async {
      print(res["message"]);
      if (res["status"] == "yes") {

        showDialog(
            context: context,
            builder: (context) =>
                Dialog(
                  backgroundColor: Colors.white,
                  child: Stack(
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                children: <Widget>[
                                  // SvgPicture.asset('images/confirmed.svg',width: MediaQuery.of(context).size.width * 0.65,),
                                  Lottie.asset(
                                    'assets/payment_successful.json',
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
                                      child: Flexible(child: Text("Payment Successful!", style: TextStyle(fontSize: textSizeLargeMedium,fontWeight: FontWeight.bold),))
                                  ),
                                  SizedBox(
                                    height: spacing_standard,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Flexible(
                                      child: Text(
                                        "Thank you for purchasing, Your payment was successfull.",
                                        style: TextStyle(
                                          fontSize: textSizeMMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: spacing_standard,
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                            Row(
                              children: <Widget>[

                                Expanded(
                                  child: InkWell(
                                    onTap: () {

                                      Navigator.of(context).pushReplacementNamed("/bottomhome");
                                    },
                                    child: Container(
                                      padding: EdgeInsets
                                          .fromLTRB(
                                          10, 10, 10, 15),
                                      alignment: Alignment
                                          .center,
                                      child: Text("Ohk",
                                        style: TextStyle(
                                            color: Colors.green
                                                .shade600,
                                            fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top:0.0,
                        right: 0.0,
                        child: new IconButton(
                            icon: Icon(Icons.cancel,color: maincolor,size: textSizeLarge,),
                            onPressed: () {
                              Navigator.pop(context,false);
                            }),
                      )
                    ],
                  ),
                )
        );

        // Navigator.of(context).pushReplacementNamed("/member");
      }
      else {
        // Fluttertoast.showToast(
        //   msg: "ERROR");
      }
    });

  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(
    //   msg: "ERROR: " + response.code.toString() + " - " + response.message,);

  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(
    //   msg: "EXTERNAL_WALLET: " + response.walletName,);
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
        Scaffold(
        drawer: DrawerNavigationBarController(),
        backgroundColor: shadecolor,
        appBar: AppBar(
          backgroundColor: maincolor,
          title: Text("Recharge Offer",style: TextStyle(color: Colors.white),),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            RefreshIndicator(
              key: _refreshIndicatorKey,
              color: maincolor,
              onRefresh: _refresh1,
              child: FutureBuilder<List<RechargeOfferList>>(
                future: RechargeOfferListdata,
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
                                // gradient: LinearGradient(
                                //     begin: Alignment.centerLeft,
                                //     end: Alignment.centerRight,
                                //     colors: [Colors.purple, Colors.blue]),
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [goldencolor, goldencolor2]),
                              // color: whitecolor,
                            ),

                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                        flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(data.ro_title==null?"":data.ro_title, style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                          SizedBox(
                                            height: spacing_middle,
                                          ),
                                          Text(data.ro_des==null?"":data.ro_des, style: TextStyle(color: whitecolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                          SizedBox(
                                            height: spacing_middle,
                                          ),
                                          // Text(data.ro_get_amt==null?"":"£"+data.ro_get_amt, style: TextStyle(color: redcolor,fontSize: textSizeSMedium, fontWeight: FontWeight.w400, letterSpacing: 0.5)),
                                          // SizedBox(
                                          //   height: spacing_middle,
                                          // ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceEvenly,
                                              children: <Widget>[
                                                InkWell(
                                                  onTap: () {

                                                    setState(() {
                                                      amt = data.ro_amt;
                                                      _amt = data.ro_get_amt;
                                                    });

                                                    if(amt==null)
                                                    {

                                                    }
                                                    else
                                                    {
                                                      // openCheckout();
                                                      setState(() {
                                                        securecode = Random().nextInt(100);
                                                      });
                                                      NetworkUtil _netUtil = new NetworkUtil();
                                                      _netUtil.post(RestDatasource.ORDERID, body: {
                                                        "securecode": securecode.toString(),
                                                        "txnid": securecode.toString(),
                                                        "amount": amt.toString(),
                                                      }).then((dynamic res) async {
                                                        if(res["status"] == "yes")
                                                        {
                                                          // FlashHelper.successBar(context, message: res['message']);
                                                          setState(() {
                                                            order_id = res['order_id'];
                                                            keyId = res['keyId'];
                                                            keySecret = res['keySecret'];
                                                          });
                                                          openCheckout();

                                                        }
                                                        else {
                                                          // FlashHelper.errorBar(context, message: res['message']);
                                                          Navigator.pop(context);
                                                        }
                                                      });

                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(0,0, 0, 0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(15.0),
                                                          topRight: Radius.circular(15.0),
                                                          bottomLeft: Radius.circular(15.0),
                                                          bottomRight: Radius.circular(15.0),
                                                        ),
                                                        color: maincolor,
                                                      ),
                                                      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                      alignment: Alignment.center,
                                                      child: Text(data.ro_amt==null?"":"Pay ".toUpperCase()+"£"+data.ro_amt,style: TextStyle(fontSize: 14,color:Colors.white,fontWeight: FontWeight.w600),),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
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
                                child: Text("Please login to take benefits of on-going offers"),
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
