import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:lottie/lottie.dart';
import 'package:dairy_connect/models/category.dart';
import 'package:dairy_connect/screens/bottom_navigation/navigation_bar_controller.dart';
import 'package:dairy_connect/utils/Constant.dart';
import 'package:dairy_connect/utils/color.dart';
import 'package:dairy_connect/utils/flash_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dairy_connect/data/rest_ds.dart';
import 'package:dairy_connect/utils/connectionStatusSingleton.dart';
import 'package:dairy_connect/utils/internetconnection.dart';
import 'package:dairy_connect/utils/network_util.dart';
import 'package:skeleton_text/skeleton_text.dart';

class CategoryScreen extends StatefulWidget {
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  BuildContext _ctx;
  RestDatasource api = new RestDatasource();
  NetworkUtil _netUtil = new NetworkUtil();
  String loggedinname = "";
  Future<List<CategoryList>> userdata;
  Future<List<CategoryList>> filterData;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  TextEditingController _searchQuery;
  bool _isSearching = false;
  String searchQuery = "Search query";

  String method_call;

  _loadPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedinname= prefs.getString("name") ?? '';
      userdata = _getData();
      filterData=userdata;
    });
  }

  Future<List<CategoryList>> _getData() async
  {
    return _netUtil.post(RestDatasource.BASE_INDEX, body: {
      'action': "method_category",
      "token":token,
      'category_status': method_call,
    }).then((dynamic res) {
      final items = res.cast<Map<String, dynamic>>();
      List<CategoryList> listofusers = items.map<CategoryList>((json) {
        return CategoryList.fromJson(json);
      }).toList();
      List<CategoryList> revdata = listofusers.reversed.toList();
      return revdata;
    });
  }

  Future<List<CategoryList>> _refresh() async
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
        Future<List<CategoryList>> items=userdata;
        List<CategoryList> filter=new List<CategoryList>();
        items.then((result){
          for(var record in result)
          {

            if(record.category_name.toLowerCase().toString().contains(searchQuery.toLowerCase()))
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
  Future<List<CategoryList>> _refresh1() async
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
      method_call = arguments['method_call'];
      // _loadPref();
    });
    if (isOffline) {
      return connection.nointernetconnection();
    } else {
      return Scaffold(
        drawer: DrawerNavigationBarController(),
        body: new NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              new SliverAppBar(
                centerTitle: true,
                title: _isSearching ? _buildSearchField() : RichText(
                  text: TextSpan(
                      text: category,
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
                child: FutureBuilder<List<CategoryList>>(
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
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed("/allproduct",
                                  arguments: {
                                    "category_id" : data.category_id,
                                  }
                              );
                            },
                            child: Column(
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
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            // SizedBox(
                                            //   width: 5,
                                            // ),
                                            (data.category_img != null) ?ClipRRect(borderRadius: BorderRadius.circular(8.0),child: new Image.network(RestDatasource.CATEGORY_IMAGE + data.category_img, width: 90, height: 90,)):ClipOval(child: new Image.asset('images/logo.png', width: 90, height: 90,)),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              data.category_name,
                                              style: TextStyle(fontSize: textSizeMMedium,fontWeight: FontWeight.w600, color: blackcolor),
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
                          ),
                      ).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }


}
