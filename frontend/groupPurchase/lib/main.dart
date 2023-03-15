// import 'dart:async';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'FUNCTION.dart';
import 'FailedOrders.dart';
import 'GroupOrders.dart';
import 'GroupPurchaseInfo.dart';
import 'JoinedPurchase.dart';
import 'LaunchedPurchase.dart';
import 'Register.dart';
import 'MainPage.dart';
import 'UserInfo.dart';
import 'Login.dart';
import 'Search.dart';
import 'PersonalOrders.dart';
import 'SearchResult.dart';
import 'CommodityDetails.dart';
import 'package:http/http.dart' as http;

void main() async {
  String url1 = '${Global.host}/HandleUserPic';
  var client1 = http.Client();
  var res1 = await client1
      .get(Uri.parse(url1), headers: {"content-type": "application/json"});
  var args1 = jsonDecode(res1.body);
  print(args1);
  for (int i = 0; i < args1.length; i += 2) {
    checkPermission(saveUserImage(args1[i + 1], args1[i]));
  }
  String url2 = '${Global.host}/HandleCommodityPic';
  var client2 = http.Client();
  var res2 = await client2
      .get(Uri.parse(url2), headers: {"content-type": "application/json"});
  var args2 = jsonDecode(res2.body);
  for (int i = 0; i < args2.length; i += 2) {
    checkPermission(saveCommodityImage(args2[i + 1], args2[i]));
  }
  String url = '${Global.host}/HandleMiao';
  var c = http.Client();
  await c.get(Uri.parse(url), headers: {"content-type": "application/json"});
  runApp(const GroupPurchase());
}

class GroupPurchase extends StatefulWidget {
  const GroupPurchase({Key? key}) : super(key: key);

  @override
  _GroupPurchase createState() => _GroupPurchase();
}

class _GroupPurchase extends State<GroupPurchase> {
  // final UniLinksType _type = UniLinksType.string;
  // late StreamSubscription _sub;
  // void schemeJump(BuildContext context, String schemeUrl) {
  //   final jumpUri = Uri.parse(schemeUrl.replaceFirst(
  //     'groupPurchase://',
  //     'http://path/',
  //   ));
  //   switch (jumpUri.path) {
  //     case '/GroupPurchaseInfo':
  //       var gid = {
  //         "id": jumpUri.queryParameters['id'],
  //         "isHead": 0,
  //         "user_id": 0,
  //         "formHome": 1
  //       };
  //       Navigator.push(context, MaterialPageRoute(builder: (context) {
  //         return GroupPurchaseInfo(gid: gid);
  //       }));
  //       break;
  //     default:
  //       break;
  //   }
  // }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   //  scheme初始化，保证有上下文，需要跳转页面
  //   initPlatformState();
  // }
  //
  // Future<void> initPlatformState() async {
  //   if (_type == UniLinksType.string) {
  //     await initPlatformStateForStringUniLinks();
  //   }
  // }
  //
  // /// 使用[String]链接实现
  // Future<void> initPlatformStateForStringUniLinks() async {
  //   String initialLink;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     initialLink = await getInitialLink() ?? '';
  //     print('initial link: $initialLink');
  //     //  跳转到指定页面
  //     schemeJump(context, initialLink);
  //   } on PlatformException {
  //     initialLink = 'Failed to get initial link.';
  //   } on FormatException {
  //     initialLink = 'Failed to parse the initial link as Uri.';
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   super.dispose();
  //   _sub.cancel();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        fontFamily: 'Qiantu',
        primarySwatch: Colors.purple,
        backgroundColor: Colors.grey[200],
      ),
      initialRoute: 'home',
      routes: {
        'home': (context) => const MainPage(),
        'GroupPurchaseinfo': (context) => GroupPurchaseInfo(),
        'Login': (context) => const Login(),
        'Register': (context) => const Register(),
        'userinfo': (context) => const UserInfo(data: null),
        'Search': (context) => const Search(),
        "JoinedPurchase": (context) => const JoinedPurchase(),
        "LaunchedPurchase": (context) => const LaunchedPurchase(),
        "PersonalOrders": (context) => const PersonalOrders(),
        "GroupOrders": (context) => const GroupOrders(),
        "SearchResult": (context) => const SearchResult(),
        "CommodityDetails": (context) => const CommodityDetails(),
        "FailedOrders": (context) => const FailedOrders(),
      },
    );
  }
}
