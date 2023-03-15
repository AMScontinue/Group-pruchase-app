import 'dart:io';

import 'package:flutter/material.dart';
import 'FUNCTION.dart';
import 'common.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupOrders extends StatelessWidget {
  const GroupOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    return GroupOrderPage(gid: args);
  }
}

class GroupOrderPage extends StatefulWidget {
  dynamic gid;

  GroupOrderPage({Key? key, required this.gid}) : super(key: key);

  @override
  State<GroupOrderPage> createState() => _GroupOrderPage(gid: gid);
}

class _GroupOrderPage extends State<GroupOrderPage> {
  dynamic gid;
  var groupinfo;
  var orderdata;
  int ordernum = 0;
  int ordertotal = 0;
  List<Order> order = [];

  _GroupOrderPage({required this.gid});

  late Future<dynamic> Receiver;

  Future getOrderByGroup_id() async {
    var body = {'group_id': gid["id"]};
    String url1 = '${Global.host}/getOneGroupInfo';
    http.Response ResForGroupInfo = await http.post(Uri.parse(url1),
        body: json.encode(body), headers: {"content-type": "application/json"});
    groupinfo = jsonDecode(ResForGroupInfo.body);
    String url2 = '${Global.host}/getGroupOrder';
    http.Response ResForOrder = await http.post(Uri.parse(url2),
        body: json.encode(body), headers: {"content-type": "application/json"});
    orderdata = jsonDecode(ResForOrder.body);
    String url4 = '${Global.host}/getGroupOrderTotal';
    http.Response ResForOrderTotal = await http.post(Uri.parse(url4),
        body: json.encode(body), headers: {"content-type": "application/json"});
    ordertotal = int.parse(ResForOrderTotal.body);
    ordernum = int.parse(orderdata[0][0]);
    for (int i = 1; i <= ordernum; i++) {
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
    return groupinfo[2];
  }

  void tryDeleteOrder(int oid) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("提示"),
              content: const Text("确定要取消该订单并退款吗？"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("取消")),
                ElevatedButton(
                    onPressed: () async {
                      var body = {'order_id': oid};
                      String url = '${Global.host}/drawbackOrder';
                      var client = http.Client();
                      await client.post(Uri.parse(url),
                          body: json.encode(body),
                          headers: {"content-type": "application/json"});
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: const Text("恭喜"),
                                content: const Text("取消成功"), //会不会不成功
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("确定")),
                                ],
                              ));
                    },
                    child: const Text("确定")),
              ],
            ));
  }

  @override
  void initState() {
    super.initState();
    Receiver = getOrderByGroup_id();
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
        child: Row(
          children: <Widget>[
            Align(
              alignment: const FractionalOffset(0.5, 0.5),
              child: Image.file(
                File("${Global.picture}/commodity-${order[index].cid}.jpg"),
                width: 140,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Wrap(
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Wrap(
                    children: [
                      const Text('用户名称：',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                      Text(
                        order[index].username.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Wrap(
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Wrap(
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Wrap(
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Wrap(
                    children: [
                      const Text('下单时间：',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Wrap(
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Wrap(
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
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    tryDeleteOrder(order[index].orderid);
                  },
                  child: const Text("取消订单并退款"),
                ),
                Container(
                  height: 20,
                ),
              ],
            ),
          ],
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
        title: const Text("管理团购订单"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder(
          future: Receiver,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              // 请求失败，显示错误
              return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
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
                            Wrap(
                              children: [
                                const Text(
                                  '团购名称:',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(width: 100),
                                Text(
                                  groupinfo[2],
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              //横轴元素个数
                              crossAxisCount: 1,
                              //纵轴间距
                              mainAxisSpacing: 20.0,
                              //横轴间距
                              crossAxisSpacing: 0.5,
                              //子组件宽高长度比例
                              childAspectRatio: 1.6),
                      itemCount: ordernum,
                      itemBuilder: _cellForRow,
                      shrinkWrap: true,
                    ),
                  ),
                ],
              );
            } else {
              // 请求未结束，显示loading
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
