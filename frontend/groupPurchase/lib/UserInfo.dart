import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouppurchase/FUNCTION.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UserInfo extends StatelessWidget {
  final dynamic data;

  const UserInfo({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return User_Info(data: data);
  }
}

// ignore: camel_case_types, must_be_immutable
class User_Info extends StatefulWidget {
  dynamic data;

  User_Info({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state, library_private_types_in_public_api
  _UserInfo createState() => _UserInfo(data: data);
}

class _UserInfo extends State<User_Info> {
  dynamic data;

  _UserInfo({required this.data});

  TextEditingController mon = TextEditingController();

  void newInfo() async {
    var body = {
      'user_id': data[0],
    };
    String url = '${Global.host}/GetSomeInfo';
    var client = http.Client();
    var response = await client.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    var args = jsonDecode(response.body);
    setState(() {
      data[3] = args[0];
      data[4] = args[1];
      data[5] = args[2];
      data[6] = args[3];
      data[7] = args[4];
    });
  }

  void empty() {}

  @override
  Widget build(BuildContext context) {
    final user = Image.file(File("${Global.picture}/user-${data[0]}.jpg"));
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        centerTitle: true,
        actions: [
          // itemCell(
          //     const Icon(
          //       Icons.email,
          //       color: Color(0xFF3479FD),
          //     ),
          //     '',
          //     "FailedOrders",
          //     data[0],
          //     int.parse(data[7]),
          //     context,
          //     newInfo),
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed("FailedOrders", arguments: data[0])
                    .then((value) => newInfo());
              },
              icon: const Icon(Icons.email))
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage("images/back.jpg"),
                      fit: BoxFit.cover,
                    )),
                    child: Text("管理"),
                  ),
                )
              ],
            ),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.account_circle)),
              title: const Text("更换账号"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, 'Login').then((value) {
                  dynamic t = jsonDecode(value.toString());
                  if (t != null) {
                    while (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    Navigator.of(context).pushNamed('home', arguments: value);
                  }
                });
              },
            ),
            //设置分割线
            const Divider(),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.exit_to_app)),
              title: const Text("退出登录"),
              onTap: () {
                while (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                Navigator.pushNamed(context, 'home');
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 100,
                  child: Container(
                    margin: const EdgeInsets.only(left: 30),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start, //元素左对齐
                        children: <Widget>[
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: user,
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[1],
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "余额:${int.parse(data[3]) / 100.0}元",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              //Spacer(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 0.5),
              color: Colors.white,
              borderRadius: BorderRadius.circular((20.0)),
            ),
            margin: const EdgeInsets.all(10),
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                itemCell(
                    const Icon(
                      Icons.group,
                      color: Color(0xFF3479FD),
                    ),
                    '发起的团购',
                    "LaunchedPurchase",
                    data[0],
                    int.parse(data[4]),
                    context,
                    newInfo),
                itemCell(
                    const Icon(
                      Icons.group_add,
                      color: Color(0xFF3479FD),
                    ),
                    '参与的团购',
                    "JoinedPurchase",
                    data[0],
                    int.parse(data[5]),
                    context,
                    newInfo),
                itemCell(
                    const Icon(
                      Icons.event_busy,
                      color: Color(0xFF3479FD),
                    ),
                    '参与订单',
                    "PersonalOrders",
                    data[0],
                    int.parse(data[6]),
                    context,
                    newInfo),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("请输入金额"),
                  content: TextFormField(
                    autofocus: true,
                    controller: mon,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                    ],
                    decoration: const InputDecoration(
                        labelText: "充值金额（单位：元）", prefixIcon: Icon(Icons.money)),
                  ),
                  actions: [
                    ElevatedButton(
                      child: const Text("取消"),
                      onPressed: () {
                        mon.clear();
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      child: const Text("确定"),
                      onPressed: () async {
                        String str = mon.text;
                        mon.clear();
                        int fen = checkEqualNum(str, context);
                        if (fen == -1) {
                          return;
                        }
                        var body = {
                          'user_id': data[0],
                          'money': fen,
                        };

                        String url = '${Global.host}/AddBalance';
                        var client = http.Client();
                        var response = await client.post(Uri.parse(url),
                            body: json.encode(body),
                            headers: {"content-type": "application/json"});
                        if (response.body == "1") {
                          //充值成功
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: const Text("恭喜"),
                                    content: const Text("充值成功"),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("确定")),
                                    ],
                                  ));
                          setState(() {
                            data[3] = (int.parse(data[3]) + fen).toString();
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 60),
            ),
            child: const Text("充值", style: TextStyle(fontSize: 35)),
          ),
          const SizedBox(
            height: 20,
          ),
          // ElevatedButton(
          //   onPressed: () async {
          //     ImagePicker image = ImagePicker();
          //     final ttt = image.pickImage(source: ImageSource.gallery);
          //   },
          //   style: ElevatedButton.styleFrom(
          //     minimumSize: const Size(120, 60),
          //   ),
          //   child: const Text("查看缓存图片", style: TextStyle(fontSize: 35)),
          // ),
        ],
      ),
    );
  }
}

Widget itemCell(Icon itemIcon, String itemTitle, String url, dynamic args,
    int count, BuildContext context, Function() trying) {
  // ignore: non_constant_identifier_names
  double c_width;
  if (count < 10) {
    c_width = 20;
  } else if (count > 100) {
    c_width = 35;
  } else {
    c_width = 30;
  }
  return GestureDetector(
    onTap: () {},
    child: Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 27,
                margin: const EdgeInsets.only(top: 0),
                child: IconButton(
                  icon: itemIcon,
                  tooltip: 'item',
                  iconSize: 30,
                  onPressed: () =>
                      Navigator.pushNamed(context, url, arguments: args)
                          .then((value) => trying()),
                ),
              ),
              Offstage(
                ///这里隐藏的条件是count=0的时候，Offstage包含的模块（角标）会隐藏，考虑的是下面没有角标的item
                offstage: count == 0,
                child: Container(
                  margin: const EdgeInsets.only(left: 30),
                  width: c_width,
                  height: 14,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomRight: Radius.circular(7),
                        topRight: Radius.circular(7)),
                    color: Color(0xFFFF491C),
                  ),
                  child: Text(
                    count >= 100 ? '99+' : count.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            width: 60,
            margin: const EdgeInsets.only(top: 35),
            child: Text(
              itemTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    ),
  );
}
