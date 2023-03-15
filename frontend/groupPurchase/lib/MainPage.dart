import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:uni_links/uni_links.dart';
import 'GroupPurchaseInfo.dart';
import 'FUNCTION.dart';
import 'HomePage.dart';
import 'UserInfo.dart';
import 'package:flutter/material.dart';
import 'createGroupPurchase.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum UniLinksType { string, uri }

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    var res = jsonDecode(args.toString());
    return MPage(data: res);
  }
}

// ignore: must_be_immutable
class MPage extends StatefulWidget {
  dynamic data;

  MPage({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _MainPage createState() => _MainPage(data: data);
}

class _MainPage extends State<MPage> {
  dynamic data;

  _MainPage({required this.data});
  //处理链接
  final UniLinksType _type = UniLinksType.string;
  late StreamSubscription _sub;
  void schemeJump(BuildContext context, String schemeUrl) {
    final jumpUri = Uri.parse(schemeUrl.replaceFirst(
      'groupPurchase://',
      'http://path/',
    ));
    switch (jumpUri.path) {
      case '/GroupPurchaseInfo':
        var tmp = jsonEncode({
          "id": jumpUri.queryParameters['id'],
          "isHead": 0,
          "user_id": 0,
          "formHome": 1
        });
        Navigator.pushNamed(context, 'GroupPurchaseinfo', arguments: tmp);
        break;
      default:
        break;
    }
  }


  Future<void> initPlatformState() async {
    if (_type == UniLinksType.string) {
      await initPlatformStateForStringUniLinks();
    }
  }

  //使用[String]链接实现
  Future<void> initPlatformStateForStringUniLinks() async {
    String initialLink;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink() ?? '';
      print('initial link: $initialLink');
      //  跳转到指定页面
      schemeJump(context, initialLink);
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
    }
    _sub = linkStream.listen((String? link) {
      if (!mounted || link == null) return;
      schemeJump(context, link);
    }, onError: (Object err) {
      if (!mounted) return;
    });
  }

  //处理底部导航栏
  int curr = 0;
  final pages = [
    const MyHomePageState(data: null),
    const createGroupPurchase(data: null),
    const UserInfo(data: null)
  ];

  createBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: curr,
      selectedLabelStyle: const TextStyle(color: Colors.purple, fontSize: 14),
      unselectedLabelStyle: const TextStyle(color: Colors.purple, fontSize: 12),
      unselectedIconTheme: const IconThemeData(color: Colors.purple),
      selectedIconTheme: const IconThemeData(color: Colors.purple),
      onTap: (index) {
        _changePage(index);
      },
      items: [
        createBottomTab(Icons.home, "首页"),
        createBottomTab(Icons.local_hospital, "创建团购"),
        createBottomTab(Icons.account_balance, "个人中心"),
      ],
    );
  }

  createBottomTab(IconData icon, String title) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: Colors.grey,
      ),
      activeIcon: Icon(
        icon,
        color: Colors.purple,
      ),
      label: title,
    );
  }

  /*切换页面*/
  void _changePage(int index) async {
    /*如果点击的导航项不是当前项  切换 */
    if (index == 0) {
      if (data != null) {
        pages[0] = MyHomePageState(data: data);
      }
    } else if (index == 1) {
      if (data == null) {
        Navigator.pushNamed(context, 'Login').then((value) {
          data = jsonDecode(value.toString());
          if (data != null) {
            pages[1] = createGroupPurchase(data: data);
            setState(() {
              curr = 1;
            });
          }
        });
        pages[1] = const createGroupPurchase(data: null);
        return;
      }
      pages[1] = createGroupPurchase(data: data);
    } else {
      if (data == null) {
        Navigator.pushNamed(context, 'Login').then((value) {
          data = jsonDecode(value.toString());
          if (data != null) {
            pages[2] = UserInfo(data: data);
            setState(() {
              curr = 2;
            });
          }
        });
        pages[2] = const UserInfo(data: null);
        return;
      }
      var body = {
        'user_id': data[0],
      };
      String url = '${Global.host}/GetSomeInfo';
      var client = http.Client();
      var response = await client.post(Uri.parse(url),
          body: json.encode(body),
          headers: {"content-type": "application/json"});
      var args = jsonDecode(response.body);
      data[3] = args[0];
      data[4] = args[1];
      data[5] = args[2];
      data[6] = args[3];
      pages[2] = UserInfo(data: data);
    }
    if (index != curr) {
      setState(() {
        curr = index;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    pages[0] = MyHomePageState(data: data);
    //  scheme初始化，保证有上下文，需要跳转页面
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: const Text('提示'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: const [Text("您确定要退出应用吗？")],
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("取消")),
                      ElevatedButton(
                          onPressed: () {
                            while (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                            SystemNavigator.pop();
                          },
                          child: const Text("确定")),
                    ],
                  ));
          return false;
        },
        child: Scaffold(
          body: pages[curr],
          bottomNavigationBar: createBottomNavigationBar(),
        ));
  }
}
