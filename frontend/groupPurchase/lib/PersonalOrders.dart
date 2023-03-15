import 'dart:io';

import 'package:flutter/material.dart';
import 'FUNCTION.dart';
import 'common.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PersonalOrders extends StatelessWidget {
  const PersonalOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    return OrderPage(uid: args);
  }
}

// ignore: must_be_immutable
class OrderPage extends StatefulWidget {
  dynamic uid;

  OrderPage({Key? key, required this.uid}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<OrderPage> createState() => _OrderPage(uid: uid);
}

class _OrderPage extends State<OrderPage> {
  dynamic uid;

  _OrderPage({required this.uid});

  // late Future<dynamic> Receiver;
  var orderdata = [];
  int ordernum = 0;
  int ordertotal = 0;
  String username = "";
  List<Order> order = [];

  // ignore: non_constant_identifier_names
  void getOrderByUser_id() async {
    orderdata = [];
    ordernum = 0;
    ordertotal = 0;
    username = "";
    order = [];
    var body = {'user_id': uid};
    String url1 = '${Global.host}/GetUsername';
    // ignore: non_constant_identifier_names
    http.Response ResForUserName = await http.post(Uri.parse(url1),
        body: json.encode(body), headers: {"content-type": "application/json"});
    username = ResForUserName.body;
    String url2 = '${Global.host}/getUserOrder';
    // ignore: non_constant_identifier_names
    http.Response ResForOrder = await http.post(Uri.parse(url2),
        body: json.encode(body), headers: {"content-type": "application/json"});
    orderdata = jsonDecode(ResForOrder.body);
    String url3 = '${Global.host}/getUserOrderAmount';
    // ignore: non_constant_identifier_names
    http.Response ResForOrderAmount = await http.post(Uri.parse(url3),
        body: json.encode(body), headers: {"content-type": "application/json"});
    ordernum = int.parse(ResForOrderAmount.body);
    String url4 = '${Global.host}/getUserOrderTotal';
    // ignore: non_constant_identifier_names
    http.Response ResForOrderTotal = await http.post(Uri.parse(url4),
        body: json.encode(body), headers: {"content-type": "application/json"});
    ordertotal = int.parse(ResForOrderTotal.body);
    int num = 0;
    if (orderdata.isEmpty) {
      num = 0;
    } else {
      num = int.parse(orderdata[0][0]);
    }
    for (int i = 1; i <= num; i++) {
      order.add(Order(
        orderid: int.parse(orderdata[i][0]),
        groupname: orderdata[i][1],
        username: orderdata[i][2],
        commodityname: orderdata[i][3],
        cid: int.parse(orderdata[i][4]),
        commodityamount: int.parse(orderdata[i][5]),
        money: int.parse(orderdata[i][6]),
        pay_time: orderdata[i][7],
        post: orderdata[i][8],
      ));
    }
    setState(() {
      username;
      orderdata;
      ordernum;
      ordertotal;
      order;
    });
  }

  @override
  void initState() {
    super.initState();
    getOrderByUser_id();
  }

  Widget _cellForRow(BuildContext context, int index) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.5),
          color: Colors.white,
          borderRadius: BorderRadius.circular((20.0)),
        ),
        margin: const EdgeInsets.all(10),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Row(
            children: <Widget>[
              Align(
                alignment: const FractionalOffset(0.5, 0.5),
                child: Image.file(
                  File("${Global.picture}/commodity-${order[index].cid}.jpg"),
                  width: 180,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    children: [
                      const Text('订单编号：',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                      Text(
                        order[index].orderid.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    children: [
                      const Text('团购名称：',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                      Text(
                        order[index].groupname,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    children: [
                      const Text('商品名称：',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                      Text(
                        order[index].commodityname,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    children: [
                      const Text('商品数量：',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                      Text(
                        order[index].commodityamount.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    children: [
                      const Text('订单价格：',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                      Text(
                        (order[index].money / 100).toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                      const Text('元',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                    ],
                  ),
                  Wrap(
                    children: const [
                      Text('下单时间：',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                    ],
                  ),
                  Wrap(
                    children: [
                      Text(
                        order[index].pay_time,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    children: [
                      const Text('物流方式：',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                      Text(
                        order[index].post,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // onTap:()=>Navigator.pushNamed(context,'OrderDetails',arguments:orderdata[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text("我的订单"),
          centerTitle: true,
        ),
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
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
                      Wrap(
                        children: [
                          const Text(
                            '用户:',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        children: [
                          const Text(
                            '共有订单数：',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            ordernum.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        children: [
                          const Text(
                            '订单总价：',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            (ordertotal / 100).toString(),
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const Text(
                            '(元)',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //横轴元素个数
                    crossAxisCount: 1,
                    //横轴间距
                    crossAxisSpacing: 2.0,
                    //子组件宽高长度比例
                    childAspectRatio: 1.5),
                itemCount: ordernum,
                itemBuilder: _cellForRow,
                shrinkWrap: true,
              ),
            ),
          ],
        ));
  }
}
