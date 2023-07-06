import 'dart:async';
import 'dart:io';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dairy_connect/models/banner.dart';
import 'package:dairy_connect/models/category.dart';
import 'package:dairy_connect/models/product.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:dairy_connect/screens/product/product/already_product_subscription_screen.dart';
import 'package:dairy_connect/screens/product/product/product_buyonce_screen.dart';
import 'package:dairy_connect/screens/product/product/product_subscription_screen.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:url_launcher/url_launcher.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  BuildContext _ctx;
  int counter = 0;
  int _current = 0;
  double u_balance,m_balance;
  String all_order="0",all_user="0",user_id,time_slot,cutoff_time,user_type,user_status,user_balance,min_balance,accept_nagative_balance;
  String old_version="16.0.0", app_version;
  int int_app_version,int_old_version=15;
  // int ov,ap;
  // Map<String, double> dataMap = Map();

  bool _isLoading = true;
  bool _isBannerLoading = true;
  bool _isdataLoading = true;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  SharedPreferences prefs;
  NetworkUtil _netUtil = new NetworkUtil();

  Future<List<ProductList>> ProductListdata;
  Future<List<ProductList>> ProductListfilterData;

  Future<List<CategoryList>> CategoryListdata;
  Future<List<CategoryList>> CategoryListfilterData;

  List<BannerList> BannerListdata;
  List<BannerList> BannerListfilterData;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey2 = new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey3 = new GlobalKey<RefreshIndicatorState>();

  _loadPref() async {
    prefs = await SharedPreferences.getInstance();

    BannerListdata = await _getBannerData();
    BannerListfilterData = BannerListdata;

    setState(() {
      user_id = prefs.getString("user_id") ?? '';
      print("User ID : "+user_id);

      ProductListdata = getProductData();
      ProductListfilterData=ProductListdata;
      //

      CategoryListdata = getCategoryData();
      CategoryListfilterData=CategoryListdata;

      user_id==null?null:_loadUser();
    });
  }

  _loadUser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString("user_id") ?? '';
      _netUtil.post(RestDatasource.GET_USER_DASHBOARD, body: {
        "user_id": user_id,
      }).then((dynamic res) async {
        setState(() {
          // print(res);
          user_status = res["user_status"].toString();
          if(user_status == "1")
          {
            time_slot = res["time_slot"].toString();
            cutoff_time = res["cutoff_time"].toString();
            user_type = res["user_type"].toString();
            user_balance = res["user_balance"].toString();
            min_balance = res["min_balance"].toString();
            accept_nagative_balance = res["accept_nagative_balance"].toString();
            u_balance = double.parse(user_balance);
            m_balance = double.parse(min_balance);

            // u_balance = res["u_balance"];
            // min_balance = res["min_balance"];
            print("user_balance : "+user_balance);
            print("min_balance : "+min_balance);
            print("user_id : "+user_id);
            print("user_type : "+user_type);
            print("user_type : "+time_slot);
          }
          else{}

          _isdataLoading = false;
        });
      });
    });
  }


  //Load Data
  Future<List<ProductList>> getProductData() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.PRODUCT, body: {
      'action': "show_product",
      "user_id": user_id,
      // "featured_product":"1",
    }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      // print(items);
      List<ProductList> listofusers = items.map<ProductList>((json) {
        return ProductList.fromJson(json);
      }).toList();
      List<ProductList> revdata = listofusers.toList();

      return revdata;
    });
  }

  //On Refresh
  Future<List<ProductList>> _refresh1() async
  {
    setState(() {
      ProductListdata = getProductData();
      ProductListfilterData=ProductListdata;
    });
  }

  //Load Data
  Future<List<CategoryList>> getCategoryData() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _netUtil.post(RestDatasource.CATEGORY, body: {
      'action': "show_category",
      'category_status': "1",
    }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      // print(items);
      List<CategoryList> listofusers = items.map<CategoryList>((json) {
        return CategoryList.fromJson(json);
      }).toList();
      List<CategoryList> revdata = listofusers.toList();

      return revdata;
    });
  }

  //On Refresh
  Future<List<CategoryList>> _refresh3() async
  {
    setState(() {
      CategoryListdata = getCategoryData();
      CategoryListfilterData=CategoryListdata;
    });
  }

  //Load Data
  _getBannerData() async
  {

    return _netUtil.post(RestDatasource.BANNER, body: {
    }).then((dynamic res)
    {
      final items = res.cast<Map<String, dynamic>>();
      print(items);
      setState(() {
        // _isLoading = false;
        _isBannerLoading = true;
      });
      List<BannerList> listofusers = items.map<BannerList>((json) {
        return BannerList.fromJson(json);
      }).toList();
      List<BannerList> revdata = listofusers.toList();
      return revdata;

    });
  }

  // On Refresh
  Future<List<BannerList>> _refresh2() async
  {
    setState(() {
      BannerListdata = _getBannerData();
      BannerListfilterData=BannerListdata;
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
    // _loadApp();
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
      const SystemUiOverlayStyle(
          statusBarColor: statusbarcolor,
          statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      drawer: DrawerNavigationBarController(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(apptitle,style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: maincolor,
        actions: [
          // profile
          GestureDetector(
            onTap: (){
              Navigator.of(context).pushNamed("/profile");
            },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Icon(Icons.person_outline),
              )
          )
        ],
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Press again to exit app'),
        ),
        child: (_isdataLoading) && (_isBannerLoading)?
        Center(
          child: Lottie.asset(
            'assets/loading.json',
            repeat: true,
            reverse: true,
            animate: true,
          ),
        ):
        ListView(
          padding: EdgeInsets.only(top: 5),
          children: [

            BannerListdata!=null? Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: SizedBox(
                height: MediaQuery.of(context).size.height*0.255,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Carousel(
                    boxFit: BoxFit.cover,
                    autoplay: true,
                    animationCurve: Curves.fastOutSlowIn,
                    animationDuration: Duration(milliseconds: 1000),
                    dotSize: 4.0,
                    dotIncreasedColor: maincolor,
                    dotBgColor: Colors.transparent,
                    dotPosition: DotPosition.bottomCenter,
                    dotVerticalPadding: 4.0,
                    showIndicator: true,
                    indicatorBgPadding: 7.0,
                    images: BannerListdata.map((item) =>
                        Container(
                          // color: maincolor,
                            height: double.infinity,
                            width: double.infinity,
                            // child: Image.network(RestDatasource.SLIDER_IMAGE+ item.banner_img)
                            child: FadeInImage(
                                width: MediaQuery.of(context).size.width * 0.50,
                                placeholder: AssetImage('images/logo.png'),
                                image: NetworkImage(RestDatasource.SLIDER_IMAGE+ item.banner_img)
                            ),
                        )
                    ).toList(),
                  ),
                ),
              ),
            ):Container(
              height: MediaQuery.of(context).size.height*0.3,
              width: MediaQuery.of(context).size.width,
              child: Image.asset('images/logo.png'),
            ),

            user_status==null?SizedBox():user_status=="1"?Container(
              child: time_slot=="No"?Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.0),
                        topRight: Radius.circular(5.0),
                        bottomLeft: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0),
                      ),
                      color: maincolor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Center(
                        child: Text("Waiting for The Dairy App response",
                          style: TextStyle(
                            color: whitecolor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ):Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    ),
                    color: maincolor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Center(
                      child: time_slot=="Morning Beach"?Text("Your Cut-off Time is $cutoff_time",
                        style: TextStyle(
                          color: whitecolor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ):Text("Your Cut-off Time is $cutoff_time",
                        style: TextStyle(
                          color: whitecolor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ):user_status=="2"?
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    ),
                    color: redcolor,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Center(
                      child: Text("Service is not available in your location",
                        style: TextStyle(
                          color: whitecolor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ):
            Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(5.0),
                    ),
                    color: maincolor,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Center(
                      child: Text("Waiting for The Dairy App response",
                        style: TextStyle(
                          color: whitecolor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    topRight: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0),
                  ),
                  color: redcolor,
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text("The Minimum order value per day must be £5 to qualify for delivery",
                    style: TextStyle(
                      color: whitecolor,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),



            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Popular Products".toUpperCase(),
                    style: const TextStyle(
                      color: textcolor,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(height: spacing_middle),
                  Container(
                      height: 260.0,
                      child: FutureBuilder<List<ProductList>>(
                        future: ProductListdata,
                        builder: (context,snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting)
                          {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: maincolor,
                                // backgroundColor: Colors.black,
                              ),
                            );
                          }
                          else if (!snapshot.hasData) {
                            return const Center(
                              child: Text("No Data Available!"),
                            );
                          }
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(top: 5),
                            children: snapshot.data
                                .map((data) =>
                                Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 2.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  child: Container(
                                    width: 150.0,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        data.product_type=="1"?InkWell(
                                          onTap: ()
                                          {
                                            // Navigator.of(context).pushNamed("/productsubscription",
                                            //     arguments: {
                                            //       "product_id" : data.product_id,
                                            //       "product_name" : data.product_name,
                                            //     });
                                            // Fluttertoast.showToast(msg: "product_id : "+data.product_id.toString() , toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: whitecolor, textColor: redcolor, fontSize: 16.0);
                                            if(data.product_type=="2")
                                            {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProductBuyOnceDetailScreen(product_id: data.product_id,product_name: data.product_name,),
                                                  ));
                                            }
                                            else{
                                            if(data.product_already=="1")
                                            {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                    builder: (context) => AlreadyProductSubscriptionDetailScreen(product_id: data.product_id,product_name: data.product_name,),
                                                  ));
                                            }else
                                            {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProductSubscriptionDetailScreen(product_id: data.product_id,product_name: data.product_name,),
                                                  ));
                                            }
                                          }},

                                          child: Container(
                                            // color: Colors.red,
                                              alignment: Alignment.topLeft,
                                              child: Center(child: (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 120, height: 120,)):ClipOval(child: new Image.asset('images/logo.png', width: 120, height: 120,)))
                                          ),
                                        ):InkWell(
                                          onTap: ()
                                          {
                                            // Navigator.of(context).pushNamed("/productbuyonce",
                                            //     arguments: {
                                            //       "product_id" : data.product_id,
                                            //       "product_name" : data.product_name,
                                            //     });
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                  builder: (context) => ProductBuyOnceDetailScreen(product_id: data.product_id,product_name: data.product_name,),
                                                ));

                                          },

                                          child: Container(
                                            // color: Colors.red,
                                              alignment: Alignment.topLeft,
                                              child: Center(child: (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 120, height: 120,)):ClipOval(child: new Image.asset('images/logo.png', width: 120, height: 120,)))
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.only(right: 10.0,left: 10.0),
                                            child: Text(
                                              data.product_name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 10.0,left: 10.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  data.product_att_value==null?"":data.product_att_value+" ",
                                                  style: const TextStyle(
                                                    color: maincolor,
                                                    fontSize: 10.0,
                                                  ),
                                                ),
                                                Text(
                                                  data.attribute_name ?? "",
                                                  style: const TextStyle(
                                                    color: maincolor,
                                                    fontSize: 10.0,
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(right: 10.0,left: 10.0),
                                          child: Row(
                                            children: [
                                              const Text(
                                                rupeesimbol,
                                                style: TextStyle(
                                                  fontSize: 11.0,
                                                ),
                                              ),
                                              user_type=="1"?Text(
                                                data.product_regular_price ?? "",
                                                style: const TextStyle(
                                                  fontSize: 11.0,
                                                ),
                                              ):Text(
                                                data.product_normal_price ?? "",
                                                style: const TextStyle(
                                                  fontSize: 11.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),

                                        data.product_type=="1"?
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10.0,left: 10.0),
                                              child: data.product_already=="1"?
                                              InkWell(
                                                onTap: ()
                                                {

                                                  // Navigator.of(context).pushNamed("/alreadyproductsubscription",
                                                  //     arguments: {
                                                  //       "product_id" : data.product_id,
                                                  //       "product_name" : data.product_name,
                                                  //     });
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                        builder: (context) => AlreadyProductSubscriptionDetailScreen(product_id: data.product_id,product_name: data.product_name,),
                                                      ));
                                                },
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0),
                                                    ),
                                                    color: greencolor,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "Subscribed".toUpperCase(),
                                                          style: const TextStyle(
                                                            color: whitecolor,
                                                            fontSize: 12.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ):
                                              InkWell(
                                                onTap: ()
                                                {
                                                  // Navigator.of(context).pushNamed("/productsubscription",
                                                  //     arguments: {
                                                  //       "product_id" : data.product_id,
                                                  //       "product_name" : data.product_name,
                                                  //     });

                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ProductSubscriptionDetailScreen(product_id: data.product_id,product_name: data.product_name,),
                                                      ));
                                                },
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0),
                                                    ),
                                                    color: maincolor,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "Subscribe".toUpperCase(),
                                                          style: const TextStyle(
                                                            color: whitecolor,
                                                            fontSize: 12.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10.0,left: 10.0),
                                              child: InkWell(
                                                onTap: ()
                                                {
                                                  // Navigator.of(context).pushNamed("/productbuyonce",
                                                  //     arguments: {
                                                  //       "product_id" : data.product_id,
                                                  //       "product_name" : data.product_name,
                                                  //     });

                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ProductBuyOnceDetailScreen(product_id: data.product_id,product_name: data.product_name,),
                                                      ));
                                                },
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0),
                                                    ),
                                                    color: Colors.blue,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "Buy Once".toUpperCase(),
                                                          style: const TextStyle(
                                                            color: whitecolor,
                                                            fontSize: 12.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ):
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10.0,left: 10.0),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(5.0),
                                                    topRight: Radius.circular(5.0),
                                                    bottomLeft: Radius.circular(5.0),
                                                    bottomRight: Radius.circular(5.0),
                                                  ),
                                                  color: whitecolor,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        "Subscribe".toUpperCase(),
                                                        style: const TextStyle(
                                                          color: whitecolor,
                                                          fontSize: 12.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10.0,left: 10.0),
                                              child: InkWell(
                                                onTap: ()
                                                {
                                                  // Navigator.of(context).pushNamed("/productbuyonce",
                                                  //     arguments: {
                                                  //       "product_id" : data.product_id,
                                                  //       "product_name" : data.product_name,
                                                  //     });

                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ProductBuyOnceDetailScreen(product_id: data.product_id,product_name: data.product_name,),
                                                      ));

                                                },
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0),
                                                    ),
                                                    color: Colors.blue,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "Buy Once".toUpperCase(),
                                                          style: const TextStyle(
                                                            color: whitecolor,
                                                            fontSize: 12.0,
                                                          ),
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
                                  ),
                                ),
                            ).toList(),
                          );
                        },
                      )
                  ),
                ],
              ),
            ),


            // Container(
            //   color : shadecolor,
            //   child: Padding(
            //     padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text("Categories".toUpperCase(),
            //           style: TextStyle(
            //             // color: whitecolor,
            //             color: textcolor,
            //             // color: maincolor,
            //             fontSize: 15.0,
            //             fontWeight: FontWeight.w700,
            //           ),
            //         ),
            //         Container(height: spacing_middle),
            //         // Container(
            //         //   height: 260,
            //         //     child: CategoryGridScreen(),
            //         // ),
            //
            //         Container(
            //             height: 150.0,
            //             child: FutureBuilder<List<CategoryList>>(
            //               future: CategoryListdata,
            //               builder: (context,snapshot) {
            //                 if (snapshot.connectionState == ConnectionState.waiting)
            //                 {
            //                   return Center(
            //                     child: CircularProgressIndicator(
            //                       color: maincolor,
            //                     ),
            //                   );
            //                 }
            //                 else if (!snapshot.hasData) {
            //                   return Center(
            //                     child: Text("No Data Available!"),
            //                   );
            //                 }
            //                 return ListView(
            //                   scrollDirection: Axis.horizontal,
            //                   padding: EdgeInsets.only(top: 5),
            //                   children: snapshot.data
            //                       .map((data) =>
            //                       InkWell(
            //                         onTap: () {
            //                           // Navigator.of(context).pushNamed("/categoryproductdetail",
            //                           Navigator.of(context).pushNamed("/allproduct",
            //                               arguments: {
            //                                 "category_id" : data.category_id,
            //                                 "category_name" : data.category_name,
            //                               });
            //                         },
            //                         child: Card(
            //                           semanticContainer: true,
            //                           clipBehavior: Clip.antiAliasWithSaveLayer,
            //                           // elevation: 2.0,
            //                           shape: RoundedRectangleBorder(
            //                             borderRadius: BorderRadius.circular(10),
            //                           ),
            //                           margin: new EdgeInsets.symmetric(
            //                               horizontal: 10.0, vertical: 5.0),
            //                           child: Container(
            //                             width: 120.0,
            //                             child: Column(
            //                               crossAxisAlignment: CrossAxisAlignment.start,
            //                               children: <Widget>[
            //                                 Container(
            //                                   // color: Colors.red,
            //                                     alignment: Alignment.topLeft,
            //                                     child: Center(child: (data.category_img != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.CATEGORY_IMAGE + data.category_img, width: MediaQuery.of(context).size.width, height: 100,)):ClipOval(child: new Image.asset('images/logo.png', width: 120, height: 120,)))
            //                                 ),
            //                                 SizedBox(
            //                                   height: 5,
            //                                 ),
            //                                 Flexible(
            //                                   child: new Container(
            //                                     padding: new EdgeInsets.only(right: 10.0,left: 10.0),
            //                                     child: Center(
            //                                       child: new Text(
            //                                         data.category_name,
            //                                         overflow: TextOverflow.ellipsis,
            //                                         style: new TextStyle(
            //                                           fontSize: 14.0,
            //                                         ),
            //                                       ),
            //                                     ),
            //                                   ),
            //                                 ),
            //
            //                               ],
            //                             ),
            //                           ),
            //                         ),
            //                       ),
            //                   ).toList(),
            //                 );
            //               },
            //             )
            //         ),
            //       ],
            //     ),
            //   ),
            // ),


            Container(
              color : shadecolor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Categories".toUpperCase(),
                      style: const TextStyle(
                        // color: whitecolor,
                        color: textcolor,
                        // color: maincolor,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(height: spacing_middle),
                    // Container(
                    //   height: 260,
                    //     child: CategoryGridScreen(),
                    // ),

                    Container(
                      // height: MediaQuery.of(context).size.height * 0.20,
                        child: FutureBuilder<List<CategoryList>>(
                          future: CategoryListdata,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (!snapshot.hasData) {
                              return const Center(
                                child: Text("No Data Available!"),
                              );
                            }
                            return GridView.count(
                              childAspectRatio: 2/2.28,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              // crossAxisCount: 2,
                              mainAxisSpacing: 5.0,
                              crossAxisSpacing: 1.0,
                              shrinkWrap: true,
                              children: snapshot.data
                                  .map(
                                    (data) =>
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: InkWell(
                                        onTap: () {
                                          // Navigator.of(context).pushNamed("/categoryproductdetail",
                                          Navigator.of(context).pushNamed("/allproduct",
                                              arguments: {
                                                "category_id" : data.category_id,
                                                "category_name" : data.category_name,
                                              });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                              bottomLeft: Radius.circular(10.0),
                                              bottomRight: Radius.circular(10.0),
                                            ),
                                            color: whitecolor,
                                            // color: blackcolor,
                                          ),
                                          // color : maincolor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              // overflow: Overflow.visible,
                                              children: [
                                                //Image
                                                Container(
                                                  // color: Colors.red,
                                                    alignment: Alignment.topLeft,
                                                    child: Center(child: (data.category_img != null) ?ClipRRect(borderRadius: BorderRadius.circular(10.0),child: new Image.network(RestDatasource.CATEGORY_IMAGE + data.category_img, width: MediaQuery.of(context).size.width, height: 100,)):ClipRRect(borderRadius: BorderRadius.circular(10.0),child: new Image.asset('images/logo.png', width: MediaQuery.of(context).size.width, height: 120,)))
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                Container(
                                                  decoration: const BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(5.0),
                                                      topRight: Radius.circular(5.0),
                                                      bottomLeft: Radius.circular(5.0),
                                                      bottomRight: Radius.circular(5.0),
                                                    ),
                                                    color: whitecolor,
                                                  ),
                                                  child: Text(
                                                    data.category_name,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ),


                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              )
                                  .toList(),
                            );
                          },
                        )),
                  ],
                ),
              ),
            ),





          ],
        ),
      ),


    );
  }
}
