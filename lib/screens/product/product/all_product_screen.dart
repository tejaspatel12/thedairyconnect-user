import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/models/category.dart';
import 'package:dairy_connect/models/product.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:dairy_connect/screens/product/product/already_product_subscription_screen.dart';
import 'package:dairy_connect/screens/product/product/product_buyonce_screen.dart';
import 'package:dairy_connect/screens/product/product/product_subscription_screen.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:skeleton_text/skeleton_text.dart';

class AllProductScreen extends StatefulWidget {
  _AllProductScreenState createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  BuildContext _ctx;

  RestDatasource api = new RestDatasource();
  NetworkUtil _netUtil = new NetworkUtil();
  String loggedinname = "",user_id;
  String category_id="",time_slot,cutoff_time,user_type;
  int num = 0;
  Future<List<ProductList>> userdata;
  Future<List<ProductList>> filterData;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  bool _isdataLoading = true;
  String searchQuery = "Search query";

  _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      num = 1;
      loggedinname= prefs.getString("name") ?? '';
      userdata = _getData();
      filterData=userdata;
    });
  }

  _loadUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString("user_id") ?? '';
      _netUtil.post(RestDatasource.GET_USER_DASHBOARD, body: {
        "user_id": user_id,
      }).then((dynamic res) async {
        setState(() {
          time_slot = res["time_slot"].toString();
          cutoff_time = res["cutoff_time"].toString();
          user_type = res["user_type"].toString();
          print("user_id : "+user_id);
          print("user_type : "+user_type);
          _isdataLoading = false;
        });
      });
    });
  }

  Future<List<ProductList>> _getData() async
  {
    return _netUtil.post(RestDatasource.PRODUCT,
        body:{
          'action': "category_product",
          'category_id': category_id,
          'user_id': user_id,
        }
    ).then((dynamic res) {
      final items = res.cast<Map<String, dynamic>>();
      List<ProductList> listofusers = items.map<ProductList>((json) {
        return ProductList.fromJson(json);
      }).toList();
      List<ProductList> revdata = listofusers.reversed.toList();
      return revdata;
    });
  }

  Future<List<ProductList>> _refresh() async
  {
    setState(() {
      userdata = _getData();
      filterData=userdata;
    });
  }

  bool isOffline = false;
  InternetConnection connection = new InternetConnection();
  StreamSubscription _connectionChangeStream;
  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus =
    ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    _loadPref();
    _searchQuery = new TextEditingController();
    _loadUser();
  }
  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
      //print(isOffline);
    });
  }

  void _startSearch() {
    //print("open search box");
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }
  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    //print("close search box");
    setState(() {
      _searchQuery.clear();
      filterData=userdata;
      updateSearchQuery("");
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      if(searchQuery.toString().length>0)
      {
        //print(searchQuery.toString().length);
        Future<List<ProductList>> items=userdata;
        List<ProductList> filter=new List<ProductList>();
        items.then((result){
          for(var record in result)
          {

            if(record.product_name.toLowerCase().toString().contains(searchQuery.toLowerCase()))
            {
              //print(record.Name);
              filter.add(record);
            }
          }
          filterData=Future.value(filter);
        });
      }
      else
      {
        filterData=userdata;
      }
    });
    print("search query1 " + newQuery);
  }
  Widget _buildSearchField() {
    return new TextField(
      controller: _searchQuery,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.white30),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: updateSearchQuery,
    );
  }
  List<Widget> _buildActions() {

    if (_isSearching) {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQuery == null || _searchQuery.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      new IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  //Load Data
  //On Refresh
  Future<List<ProductList>> _refresh1() async
  {
    setState(() {
      userdata = _getData();
      filterData=userdata;
    });
  }


  @override
  Widget build(BuildContext context) {
     setState(() {
       _ctx = context;
       final Map arguments = ModalRoute.of(_ctx).settings.arguments as Map;
       category_id = arguments['category_id'];
       print(category_id);
       num == 0 ?
       _loadPref() : null;
       // _loadPref();
     });
    print("Product");
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        body: SafeArea(
          child: new NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  centerTitle: true,
                  title: _isSearching ? _buildSearchField() : RichText(
                    text: TextSpan(
                        text: product,
                        style: TextStyle(color: Colors.white, fontSize: 17,fontWeight: FontWeight.bold),

                        children: [
                          TextSpan(text: "",
                              style: TextStyle(color: Colors.white, fontSize: 15))
                        ]),
                  ),
                  actions: _buildActions(),
                  backgroundColor: maincolor,
                  iconTheme: IconThemeData(color: Colors.white),
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,

                ),
              ];
            },
            body: Stack(
              children: <Widget>[
                RefreshIndicator(
                  key: _refreshIndicatorKey,
                  color: maincolor,
                  onRefresh: _refresh,
                  child: FutureBuilder<List<ProductList>>(
                    future: filterData,
                    builder: (context, snapshot) {
                      //print(snapshot.data);
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Lottie.asset(
                            'assets/loading.json',
                            repeat: true,
                            reverse: true,
                            animate: true,
                          ),

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
                        padding: EdgeInsets.only(top: 15),
                        children: snapshot.data
                            .map((data) =>
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: bordercolor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: productboxcolor,
                                  ),
                                  margin: new EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 5.0),
                                  // color:Colors.red.shade400,
                                  // decoration: BoxDecoration(
                                  //     gradient: LinearGradient(
                                  //         colors: [Colors.lightGreen.shade600, Colors.lightGreen.shade400, Colors.lightGreen.shade500],
                                  //         begin: Alignment.bottomCenter,
                                  //         end: Alignment.topCenter,
                                  //         stops: [0.2,0.6,1]
                                  //     )
                                  // ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            // SizedBox(
                                            //   width: 5,
                                            // ),
                                            InkWell(
                                                onTap: ()
                                                {
                                                  // Navigator.of(context).pushNamed("/productsubscription",
                                                  //     arguments: {
                                                  //       "product_id" : data.product_id,
                                                  //       "product_name" : data.product_name,
                                                  //     });
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
                                                  }}

                                                  // Navigator.push(context,
                                                  //     MaterialPageRoute(
                                                  //       builder: (context) => ProductSubscriptionDetailScreen(product_id: data.product_id,product_name: data.product_name,),
                                                  //     ));
                                                },
                                                child: (data.product_image != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.PRODUCT_IMAGE + data.product_image, width: 120, height: 120,)):ClipOval(child: new Image.asset('images/logo.png', width: 120, height: 120,))
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Flexible(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          data.product_name,
                                                          style: TextStyle(fontSize: textSizeMedium,fontWeight: FontWeight.w600, color: blackcolor),
                                                        ),
                                                        SizedBox(
                                                          height: spacing_control,
                                                        ),
                                                        user_type=="1"?Row(
                                                          children: [
                                                            Text(
                                                              "Price : ",
                                                              style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: maincolor),
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                data.product_regular_price==null?"":data.product_regular_price,
                                                                style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: maincolor),
                                                              ),
                                                            ),
                                                          ],
                                                        ):Row(
                                                          children: [
                                                            Text(
                                                              "Price : ",
                                                              style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: maincolor),
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                data.product_normal_price==null?"":data.product_normal_price,
                                                                style: TextStyle(fontSize: textSizeSMedium,fontWeight: FontWeight.w600, color: maincolor),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: spacing_control,
                                                        ),
                                                        data.product_type=="1"?Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            data.product_already=="1"?InkWell(
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
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(5.0),
                                                                    topRight: Radius.circular(5.0),
                                                                    bottomLeft: Radius.circular(5.0),
                                                                    bottomRight: Radius.circular(5.0),
                                                                  ),
                                                                  color: greencolor,
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                                                                  child: new Text(
                                                                    "Subscribed".toUpperCase(),
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: 12.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ):InkWell(
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
                                                                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                                                                  child: new Text(
                                                                    "Subscribe".toUpperCase(),
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: 12.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            InkWell(
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
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(5.0),
                                                                    topRight: Radius.circular(5.0),
                                                                    bottomLeft: Radius.circular(5.0),
                                                                    bottomRight: Radius.circular(5.0),
                                                                  ),
                                                                  color: Colors.blue,
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                                                                  child: new Text(
                                                                    "Buy Once".toUpperCase(),
                                                                    style: new TextStyle(
                                                                      color: whitecolor,
                                                                      fontSize: 12.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ):
                                                        InkWell(
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
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(5.0),
                                                                topRight: Radius.circular(5.0),
                                                                bottomLeft: Radius.circular(5.0),
                                                                bottomRight: Radius.circular(5.0),
                                                              ),
                                                              color: Colors.blue,
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                                                              child: new Text(
                                                                "Buy Once".toUpperCase(),
                                                                style: new TextStyle(
                                                                  color: whitecolor,
                                                                  fontSize: 12.0,
                                                                ),
                                                              ),
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

                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                        ).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }


}
