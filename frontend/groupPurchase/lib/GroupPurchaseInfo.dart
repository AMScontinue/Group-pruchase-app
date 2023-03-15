import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'FUNCTION.dart';
import 'common.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

//future中自带setState()method,不用自己再写一个

class GroupPurchaseInfo extends StatelessWidget {
  const GroupPurchaseInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    dynamic data = jsonDecode(args.toString());
    return Gpage(gid: data);
  }
}

// ignore: must_be_immutable
class Gpage extends StatefulWidget {
  dynamic gid;

  Gpage({Key? key, required this.gid}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _GroupPurchaseInfo createState() => _GroupPurchaseInfo(gid: gid);
}

class _GroupPurchaseInfo extends State<Gpage> {
  dynamic gid;
  dynamic data;

  _GroupPurchaseInfo({required this.gid});

  TextEditingController cha = TextEditingController();

  List<TextEditingController> input =
      List.generate(5, (i) => TextEditingController());

  bool miao = false;

  var groupdata = [];
  List<Commodity> commodity = [];

  // ignore: non_constant_identifier_names
  List<int> commodity_id = [];
  groupInfo info = const groupInfo(
      id: 0,
      name: '',
      description: '',
      begin_time: '',
      end_time: '',
      post: '',
      commodity: [],
      participants: 0,
      link: '');

  // ignore: non_constant_identifier_names
  void getGroupBygroup_id() async {
    groupdata.clear();
    commodity.clear();
    commodity_id.clear();
    var body = {'group_id': gid["id"]};
    String url = '${Global.host}/getOneGroupInfo';
    http.Response response = await http.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    groupdata = jsonDecode(response.body);
    for (int i = 0; i < int.parse(groupdata[0]); ++i) {
      int offset = 7 * i;
      commodity_id.add(int.parse(groupdata[10 + offset]));
      bool tmp;
      if (groupdata[16 + offset] == "1") {
        tmp = true;
      } else {
        tmp = false;
      }
      commodity.add(Commodity(
          cid: int.parse(groupdata[10 + offset]),
          name: groupdata[11 + offset],
          imageUrl: groupdata[13 + offset],
          description: groupdata[12 + offset],
          price: int.parse(groupdata[15 + offset]),
          number: int.parse(groupdata[14 + offset]),
          miao: tmp));
    }
    info = groupInfo(
        id: int.parse(groupdata[1]),
        name: groupdata[2],
        description: groupdata[3],
        begin_time: groupdata[7],
        end_time: groupdata[8],
        post: groupdata[4],
        participants: int.parse(groupdata[5]),
        commodity: commodity,
        link: "");
    setState(() {
      groupdata;
      commodity;
      commodity_id;
      info;
    });
  }

  @override
  void initState() {
    super.initState();
    getGroupBygroup_id();
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
            child: Column(
              children: <Widget>[
                Align(
                  alignment: const FractionalOffset(0.5, 0.5),
                  child: Image.file(
                    File(
                        "${Global.picture}/commodity-${info.commodity[index].cid}.jpg"),
                    width: 100,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        const Text('商品名称：',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18.0,
                            )),
                        Text(
                          info.commodity[index].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        const Text('价格 ：',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18.0,
                            )),
                        Text(
                          ((info.commodity[index].price) / 100.0).toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 20.0,
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
                      children: [
                        const Text('库存：',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18.0,
                            )),
                        Text(
                          info.commodity[index].number.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        const Text('描述：',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18.0,
                            )),
                        Text(
                          info.commodity[index].description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        Text(
                          info.commodity[index].miao ? "可秒杀" : "",
                          style: const TextStyle(
                            fontSize: 23,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                gid["head"] == "1"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            ElevatedButton(
                              onPressed: () {
                                showBottom(index);
                              },
                              child: const Text("修改"),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                tryDeleteOne(index);
                              },
                              child: const Text("删除"),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ])
                    : const SizedBox(
                        height: 10,
                      ),
                Container(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          String tmp = jsonEncode({
            'user_id': gid["user_id"],
            'commodity_id': commodity_id[index],
          });
          Navigator.pushNamed(context, 'CommodityDetails', arguments: tmp)
              .then((value) async {
            dynamic t = jsonDecode(value.toString());
            var body = {
              'id': gid["id"],
              'user_id': t[0],
            };
            String url = '${Global.host}/CheckHead';
            var client = http.Client();
            var response = await client.post(Uri.parse(url),
                body: json.encode(body),
                headers: {"content-type": "application/json"});
            setState(() {
              data = value;
              gid["user_id"] = t[0];
              gid["head"] = response.body;
            });
            getGroupBygroup_id();
          });
        });
  }

  void tryDeleteOne(int index) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("提示"),
              content: const Text("确定要删除该商品吗？"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("取消")),
                ElevatedButton(
                    onPressed: () async {
                      var body = {
                        'group_id': gid["id"],
                        'commodity_id': commodity_id[index],
                      };
                      String url = '${Global.host}/DeleteCommodity';
                      var client = http.Client();
                      await client.post(Uri.parse(url),
                          body: json.encode(body),
                          headers: {"content-type": "application/json"});
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: const Text("恭喜"),
                                content: const Text("删除成功"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        //同样只有团长能改
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("确定")),
                                ],
                              ));
                    },
                    child: const Text("确定")),
              ],
            )).then((value) => getGroupBygroup_id());
  }

  void tryDeleteGroup() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("提示"),
              content: const Text("确定要删除该团购吗？"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("取消")),
                ElevatedButton(
                    onPressed: () async {
                      var body = {'group_id': gid["id"]};
                      String url = '${Global.host}/DeleteGroup';
                      var client = http.Client();
                      await client.post(Uri.parse(url),
                          body: json.encode(body),
                          headers: {"content-type": "application/json"});
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: const Text("恭喜"),
                                content: const Text("删除成功"),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        //同样只有团长能改
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        print("data=");
                                        print(data);
                                        Navigator.of(context).pop(data);
                                      },
                                      child: const Text("确定")),
                                ],
                              ));
                    },
                    child: const Text("确定")),
              ],
            ));
  }

  void tryFinishGroup() {
    DateTime dateTime = DateTime.now();
    String endTime = dateTime.toString().substring(0, 16);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("提示"),
              content: const Text("确定要结束该团购吗？"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("取消")),
                ElevatedButton(
                    onPressed: () async {
                      var body = {'group_id': gid["id"], 'end_time': endTime};
                      String url = '${Global.host}/FinishGroup';
                      var client = http.Client();
                      var res = await client.post(Uri.parse(url),
                          body: json.encode(body),
                          headers: {"content-type": "application/json"});
                      int t = int.parse(res.body);
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: t == 0
                                    ? const Text("恭喜")
                                    : const Text("提示"),
                                content: t == 0
                                    ? const Text("团购已成功结束")
                                    : SingleChildScrollView(
                                        child: Column(children: [
                                          const Text("操作失败"),
                                          t == 1
                                              ? const Text("原因：团购尚未开始")
                                              : const Text("原因：团购已经结束")
                                        ]),
                                      ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        //同样只有团长能改
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("确定")),
                                ],
                              ));
                    },
                    child: const Text("确定")),
              ],
            )).then((value) => getGroupBygroup_id());
  }

  void showBottom(int type) {
    List<String> options = (type == -1)
        ? ["团购名称", "团购描述", "物流方式", "开始时间", "结束时间"]
        : ["图片", "商品名称", "商品价格", "库存", "描述", "是否可秒杀"];
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView(children: <Widget>[
            for (int j = 0; j < options.length; j++)
              TextButton(
                onPressed: () => showChangeDialog(type, j),
                child: Text(options[j]),
              ),
          ]);
        });
  }

  void showChangeDialog(int type, int index) {
    bool miao = false;
    if (type >= 0) {
      miao = commodity[type].miao;
    }
    String time = "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("请输入内容"),
        content: index < 5
            ? ((index >= 3 && type == -1)
                ? DateTimePicker(
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900),
                    type: DateTimePickerType.dateTime,
                    dateMask: 'yyyy-MM-dd HH:mm',
                    initialValue: DateTime.now().toString(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2025),
                    icon: const Icon(Icons.event),
                    dateLabelText: '日期',
                    onChanged: (val) {
                      time = val;
                    },
                    onSaved: (val) {
                      time = val!;
                    })
                : TextFormField(
                    autofocus: true,
                    controller: cha,
                    inputFormatters: (type == -1 || (index != 2 && index != 3))
                        ? null
                        : ((index == 2)
                            ? [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9.]"))
                              ]
                            : [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9]"))
                              ]),
                    decoration:
                        const InputDecoration(prefixIcon: Icon(Icons.input)),
                  ))
            : StatefulBuilder(
                builder: (context, setstate) => Wrap(children: [
                      const Text(
                        '秒杀:',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 100),
                      Switch(
                        value: miao,
                        onChanged: (value) {
                          //重新构建页面
                          setState(() {
                            miao = value;
                          });
                          setstate(() {
                            miao = value;
                          });
                        },
                      )
                    ])),
        actions: [
          TextButton(
            child: const Text("取消"),
            onPressed: () {
              cha.clear();
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text("确定"),
            onPressed: () async {
              String ch;
              if (index < 5) {
                if (index >= 3 && type == -1) {
                  ch = time;
                } else {
                  ch = cha.text;
                }
              } else {
                ch = miao.toString();
              }
              cha.clear();
              if (type >= 0 && index == 2) {
                int fen = checkEqualNum(ch, context);
                if (fen == -1) {
                  return;
                } else {
                  ch = fen.toString();
                }
              }
              var body = {};
              if (type == -1) {
                body = {
                  'group_id': gid["id"],
                  'type': index,
                  'inner': ch,
                };
              } else {
                body = {
                  'commodity_id': commodity_id[type],
                  'type': index,
                  'inner': ch,
                };
              }
              String url = (type == -1)
                  ? '${Global.host}/UpdateGroup'
                  : '${Global.host}/UpdateCommodity';
              var client = http.Client();
              await client.post(Uri.parse(url),
                  body: json.encode(body),
                  headers: {"content-type": "application/json"});
              showDialog(
                  routeSettings: const RouteSettings(arguments: true),
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text("恭喜"),
                        content: const Text("修改成功"),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                //只有团长可以修改，入口固定
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text("确定")),
                        ],
                      ));
            },
          ),
        ],
      ),
    ).then((value) => getGroupBygroup_id());
  }

  void showAdder() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setstate) => AlertDialog(
                    title: const Text("请输入内容"),
                    content: SingleChildScrollView(
                      child: Column(children: [
                        TextFormField(
                          autofocus: true,
                          controller: input[0],
                          decoration: const InputDecoration(
                              labelText: "商品图片", prefixIcon: Icon(Icons.image)),
                        ),
                        TextFormField(
                          autofocus: true,
                          controller: input[1],
                          decoration: const InputDecoration(
                              labelText: "商品名称", prefixIcon: Icon(Icons.title)),
                        ),
                        TextFormField(
                          autofocus: true,
                          controller: input[2],
                          decoration: const InputDecoration(
                              labelText: "商品价格",
                              prefixIcon: Icon(Icons.price_check)),
                        ),
                        TextFormField(
                          autofocus: true,
                          controller: input[3],
                          decoration: const InputDecoration(
                              labelText: "商品库存",
                              prefixIcon: Icon(Icons.numbers)),
                        ),
                        TextFormField(
                          autofocus: true,
                          controller: input[4],
                          decoration: const InputDecoration(
                              labelText: "商品描述", prefixIcon: Icon(Icons.book)),
                        ),
                        Wrap(
                          children: [
                            const Text(
                              '秒杀:',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 100),
                            Switch(
                              value: miao, //当前状态
                              onChanged: (value) {
                                //重新构建页面
                                setState(() {
                                  miao = value;
                                });
                                setstate(() {
                                  miao = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ]),
                    ),
                    actions: [
                      TextButton(
                        child: const Text("取消"),
                        onPressed: () {
                          for (int i = 0; i < 5; i++) {
                            input[i].clear();
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text("确定"),
                        onPressed: () async {
                          double pri = double.parse(input[2].text);
                          int pr = (pri * 100).floor();
                          cha.clear();
                          var body = {
                            "group_id": gid["id"],
                            "image_url": input[0].text,
                            "commodity_name": input[1].text,
                            "price": pr,
                            "inventory": input[3].text,
                            "des": input[4].text,
                            "miao": miao,
                          };
                          miao = false;
                          String url = '${Global.host}/CreateCommodity';
                          var client = http.Client();
                          var res = await client.post(Uri.parse(url),
                              body: json.encode(body),
                              headers: {"content-type": "application/json"});
                          checkPermission(
                              saveCommodityImage(input[0].text, res.body));
                          for (int i = 0; i < 5; i++) {
                            input[i].clear();
                          }
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: const Text("恭喜"),
                                    content: const Text("添加成功"),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            //同样只有团长能改
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("确定")),
                                    ],
                                  ));
                        },
                      ),
                    ],
                  ));
        }).then((value) => getGroupBygroup_id());
  }

  @override
  Widget build(BuildContext context) {
    if (groupdata.isEmpty) {
      return const Scaffold();
    }
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop(data);
              },
              icon: const Icon(Icons.arrow_back)),
          title: const Text(
            '团购信息',
            //style: const TextStyle(fontFamily: 'Qiantu')
          ),
          centerTitle: true,
          actions: gid["head"] == "1"
              ? [
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showBottom(-1);
                            });
                          },
                          child: const Text("修改团购基本信息"),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showAdder();
                            });
                          },
                          child: const Text("添加商品"),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              tryFinishGroup();
                            });
                          },
                          child: const Text("结束该团购"),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              tryDeleteGroup();
                            });
                          },
                          child: const Text("删除该团购"),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.of(context)
                                  .pushNamed('GroupOrders', arguments: gid);
                            });
                          },
                          child: const Text("管理该团购订单"),
                        )
                      ];
                    },
                  )
                ]
              : null,
        ),
        body: Column(
          children: [
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                            info.name,
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
                            '描述：',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            info.description,
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
                            '物流方式:',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            info.post,
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
                            '开始时间:',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            info.begin_time,
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
                            '结束时间:',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 100),
                          Text(
                            info.end_time,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //横轴元素个数
                    crossAxisCount: 2,
                    //纵轴间距
                    mainAxisSpacing: 20.0,
                    //横轴间距
                    crossAxisSpacing: 2.0,
                    //子组件宽高长度比例
                    childAspectRatio: 0.64),
                itemCount: int.parse(groupdata[0]),
                itemBuilder: _cellForRow,
                shrinkWrap: true,
              ),
            ),
          ],
        ));
  }
}
