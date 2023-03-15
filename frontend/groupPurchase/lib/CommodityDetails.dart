import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'package:grouppurchase/FUNCTION.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: prefer_typing_uninitialized_variables
var commoditydata;
int commodityAmount = 0;
Commodity commodityInfo = const Commodity(
    cid: 0,
    name: '',
    imageUrl: '',
    description: '',
    price: 0,
    number: 0,
    miao: false);

class CommodityDetails extends StatelessWidget {
  const CommodityDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    dynamic data = jsonDecode(args.toString());
    return CommodityPage(cid: data);
  }
}

// ignore: must_be_immutable
class CommodityPage extends StatefulWidget {
  dynamic cid;

  CommodityPage({Key? key, required this.cid}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<CommodityPage> createState() => _CommodityPage(cid: cid);
}

class _CommodityPage extends State<CommodityPage> {
  dynamic cid;
  dynamic data;

  // ignore: non_constant_identifier_names
  TextEditingController Num = TextEditingController();

  _CommodityPage({required this.cid});

  // ignore: non_constant_identifier_names
  late Future<dynamic> Receiver;

  // ignore: non_constant_identifier_names
  Future getCommodityByCommodity_id() async {
    var body = {'commodity_id': cid["commodity_id"]};
    String url = '${Global.host}/getCommodityInfoByCommodity_id';
    http.Response ResForCommodityInfo = await http.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    commoditydata = jsonDecode(ResForCommodityInfo.body);
    bool tmp;
    if (commoditydata[5] == "1") {
      tmp = true;
    } else {
      tmp = false;
    }
    commodityInfo = Commodity(
        cid: cid["commodity_id"],
        name: commoditydata[0],
        imageUrl: commoditydata[1],
        description: commoditydata[2],
        price: int.parse(commoditydata[3]),
        number: int.parse(commoditydata[4]),
        miao: tmp);
    return commodityInfo;
  }

  @override
  void initState() {
    super.initState();
    Receiver = getCommodityByCommodity_id();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop(data);
              },
              icon: const Icon(Icons.arrow_back)),
          title: const Text("商品详情"),
          centerTitle: true,
        ),
        backgroundColor: Colors.grey[200],
        body: FutureBuilder(
            future: Receiver,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Text("Error:${snapshot.error}");
              } else if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 100, 10, 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 0.5),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular((20.0)),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: const FractionalOffset(0.5, 0.5),
                              child: Image.file(
                                File(
                                    "${Global.picture}/commodity-${commodityInfo.cid}.jpg"),
                                width: 180,
                              ),
                            ),
                            Wrap(children: [
                              const Text('商品名称:',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 100),
                              Text(commodityInfo.name,
                                  style: const TextStyle(fontSize: 20))
                            ]),
                            const SizedBox(height: 10),
                            Wrap(children: [
                              const Text('商品价格:',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 100),
                              Text((commodityInfo.price / 100).toString(),
                                  style: const TextStyle(fontSize: 20))
                            ]),
                            const SizedBox(height: 10),
                            Wrap(children: [
                              const Text('库存数量:',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 100),
                              Text(commodityInfo.number.toString(),
                                  style: const TextStyle(fontSize: 20))
                            ]),
                            const SizedBox(height: 10),
                            Wrap(children: [
                              const SizedBox(width: 160),
                              Text(commodityInfo.miao ? "可秒杀" : "售完即止",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.red))
                            ]),
                            const SizedBox(height: 10),
                            Wrap(children: [
                              const Text('商品详情:',
                                  style: TextStyle(fontSize: 20)),
                              //   const SizedBox(width: 100),
                              Text(commodityInfo.description,
                                  style: const TextStyle(fontSize: 20))
                            ]),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (cid['user_id'] == '0') {
                            Navigator.pushNamed(context, 'Login').then((value) {
                              var user = jsonDecode(value.toString());
                              if (user != null) {
                                setState(() {
                                  data = value;
                                  cid['user_id'] = user[0];
                                });
                              }
                            });
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("请输入想要购买的数量:"),
                              content: TextFormField(
                                autofocus: true,
                                controller: Num,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]")),
                                ],
                                decoration: const InputDecoration(
                                    labelText: "购买数量",
                                    prefixIcon: Icon(Icons.shopping_cart)),
                              ),
                              actions: [
                                ElevatedButton(
                                  child: const Text("取消"),
                                  onPressed: () {
                                    Num.clear();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text("确定"),
                                  onPressed: () async {
                                    String str = Num.text;
                                    Num.clear();
                                    int amount =
                                        checkEqualInteger(str, context);
                                    var body = {
                                      'commodity_id': cid["commodity_id"],
                                      'commodity_amount': amount,
                                      'user_id': cid["user_id"],
                                      'pay_time': DateTime.now()
                                          .toString()
                                          .substring(0, 16),
                                    };

                                    String url = '${Global.host}/CreateOrder';
                                    var client = http.Client();
                                    var response = await client.post(
                                        Uri.parse(url),
                                        body: json.encode(body),
                                        headers: {
                                          "content-type": "application/json"
                                        });
                                    if (response.body == "success") {
                                      //购买成功
                                      showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                                title: const Text("成功"),
                                                content: const Text(
                                                    "订单已经完成，详情请见个人中心"),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("确定")),
                                                ],
                                              ));
                                      setState(() {});
                                    } else if (response.body == "Time") {
                                      //购买成功
                                      showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                                title: const Text("创建失败"),
                                                content: const Text(
                                                    "当前不在可购买的团购时间内！"),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("确定")),
                                                ],
                                              ));
                                      setState(() {});
                                    } else if (response.body == "Inventory") {
                                      //购买成功
                                      showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                                title: const Text("创建失败"),
                                                content: const Text("商品库存不足！"),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("确定")),
                                                ],
                                              ));
                                      setState(() {});
                                    } else if (response.body == "Money") {
                                      //购买成功
                                      showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                                title: const Text("创建失败"),
                                                content: const Text("用户余额不足！"),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text("确定")),
                                                ],
                                              ));
                                      setState(() {});
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
                        child: const Text("购买", style: TextStyle(fontSize: 35)),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
