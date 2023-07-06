import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dairy_connect/routes.dart';
import 'package:dairy_connect/utils/color.dart';

import 'data/database_helper.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     importance: Importance.high,
//     playSound: true);
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('A bg message just showed up :  ${message.messageId}');
// }

Future<void> main() async {

  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  //
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  runApp(LoginApp());
}

// Future<void> backgroundHandler (RemoteMessage message) async {
//   print(message.data.toString());
//   print(message.notification.title);
// }

// void main() => runApp(new LoginApp());
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
//
//   // await Firebase.initializeApp(
//   //   options: DefaultFirebaseOptions.currentPlatform,
//   // );
//   runApp(LoginApp());


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(LoginApp());
// }

class LoginApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    // FirebaseMessaging.instance.getToken().then((value) {
    //   print("Token :"+value);
    // });

    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: 'Noorani Dairy Farm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // primarySwatch:Colors.blue,
        // accentColor: Colors.blueAccent.shade700,
        accentColor: Color(0xFF6A3DE8),
        primaryColor: Color(0xFF6A3DE8),
      ),
      routes: routes,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

// final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class _SplashScreenState extends State<SplashScreen>{
  BuildContext _ctx;

  startTime() async {
    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() async {
    var db = DatabaseHelper();
    var isLoggedIn = await db.isLoggedIn();
    if(isLoggedIn) {
      Navigator.of(context).pushNamedAndRemoveUntil('/bottomhome', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/check', (Route<dynamic> route) => false);
    }
  }

  // void navigationPage() async {
  //   Navigator.of(context).pushNamedAndRemoveUntil('/bottomhome', (Route<dynamic> route) => false);
  // }

  // getToken() async {
  //   final fcmToken = await FirebaseMessaging.instance.getToken();
  //   print(fcmToken);
  //   await FirebaseMessaging.instance.setAutoInitEnabled(true);
  // }
  @override
  void initState() {
    super.initState();

    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method

    // FirebaseMessaging.instance.getInitialMessage().then(
    //       (message) {
    //     print("FirebaseMessaging.instance.getInitialMessage");
    //     if (message != null) {
    //       print("New Notification");
    //       // if (message.data['_id'] != null) {
    //       //   Navigator.of(context).push(
    //       //     MaterialPageRoute(
    //       //       builder: (context) => DemoScreen(
    //       //         id: message.data['_id'],
    //       //       ),
    //       //     ),
    //       //   );
    //       // }
    //     }
    //   },
    // );
    //
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             color: Colors.blue,
    //             playSound: true,
    //             icon: '@mipmap/ic_launcher',
    //           ),
    //         ));
    //   }
    // });
    //
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('A new onMessageOpenedApp event was published!');
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     showDialog(
    //         context: context,
    //         builder: (_) {
    //           return AlertDialog(
    //             title: Text(notification.title),
    //             content: SingleChildScrollView(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [Text(notification.body)],
    //               ),
    //             ),
    //           );
    //         });
    //   }
    // });






    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage1: $message");
    //     print("page : "+message['data']['page']);
    //     if(message['data']['page']=="notification")
    //     {
    //       Navigator.of(context).popAndPushNamed("/notifications");
    //     }
    //     //_showItemDialog(message);
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     //_navigateToItemDetail(message);
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //     // _navigateToItemDetail(message);
    //   },
    // );
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(
    //         sound: true, badge: true, alert: true, provisional: true));
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   setState(() {
    //     print("Push Messaging token: $token");
    //   });
    // });

    // getToken();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadecolor,
      body: Center(
        child: Container(
          // color: shadecolor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/logo.png',
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.5,
              ),

            ],
          ),
        ),
      ),
    );
  }
}