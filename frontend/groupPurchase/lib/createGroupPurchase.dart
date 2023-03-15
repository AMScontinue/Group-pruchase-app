import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/services.dart';
import 'package:grouppurchase/FUNCTION.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: camel_case_types
class createGroupPurchase extends StatefulWidget {
  final dynamic data;

  const createGroupPurchase({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _createGroupPurchase createState() => _createGroupPurchase(data: data);
}

// ignore: camel_case_types
class _createGroupPurchase
    extends State<createGroupPurchase> /* with AutomaticKeepAliveClientMixin*/ {
  dynamic data;

  _createGroupPurchase({required this.data});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _groupname;
  late String _groupdes;
  late String _grouppost;
  late String _begintime;
  late String _endtime;
  late int _groupid;
  late String _grouplink;

  var commodityWidget = <Widget>[];

  void removeMetaRow(Widget w) {
    commodityWidget.remove(w);
    setState(() {});
  }

  Future<int> createGroupInfo() async {
    var body = {
      "group_name": _groupname,
      "des": _groupdes,
      "post": _grouppost,
      "begin_time": _begintime,
      "end_time": _endtime,
      "head_id": data[0],
    };
    String url = '${Global.host}/CreateGroup';
    http.Response response = await http.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    _groupid = int.parse(jsonDecode(response.body).toString());
    return _groupid;
  }

  Future<Future> _forSubmitted() async {
    final form = _formKey.currentState;
    if (form != null && !form.validate()) {
      // Invalid!
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('提示'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const [Text("信息不完善")],
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("确定")),
                ],
              ));
    } else if (DateTime.parse(_endtime).isBefore(DateTime.parse(_begintime))) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('提示'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: const [Text("时间信息有误")],
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("确定")),
                ],
              ));
    }

    form?.save();
    await createGroupInfo();
    var link = {"group_id": _groupid};
    String url = '${Global.host}/GetLink';
    http.Response response = await http.post(Uri.parse(url),
        body: json.encode(link), headers: {"content-type": "application/json"});
    _grouplink = response.body;
    for (int j = 0; j < commodityWidget.length; ++j) {
      Row_meta rm = commodityWidget[j] as Row_meta;
      rm.context = context;
      rm.createCommodityInfo(_groupid);
    }
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('提示'),
              content: SingleChildScrollView(
                child: ListBody(
                  children:  [
                    const Text("团购创建成功"),
                    const Text("您的链接为"),
                    Wrap(
                    children:[Text(_grouplink)],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, 'home',
                          arguments: jsonEncode(data));
                    },
                    child: const Text("确定")),
              ],
            ));
  }

  @override
  void initState() {
    commodityWidget.add(Row_meta(UniqueKey(), removeMetaRow));
  }

  // @override
  // bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建你的团购'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[200],
      body: ListView(
        shrinkWrap: true,
        children: [
          Form(
            key: _formKey,
            child: Column(children: [
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
                        TextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          validator: (String? val) {
                            return (val?.length)! >= 1 ? null : '不能为空';
                          },
                          onSaved: (val) {
                            _groupname = val!;
                          },
                          onChanged: (val) {
                            _groupname = val;
                          },
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: "此商品名称",
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        const Text(
                          '描述：',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 100),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          validator: (String? val) {
                            return (val?.length)! >= 1 ? null : '不能为空';
                          },
                          onSaved: (val) {
                            _groupdes = val!;
                          },
                          onChanged: (val) {
                            _groupdes = val;
                          },
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: "对团购的描述",
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        const Text(
                          '物流方式:',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 100),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          validator: (String? val) {
                            return (val?.length)! >= 1 ? null : '不能为空';
                          },
                          onSaved: (val) {
                            _grouppost = val!;
                          },
                          onChanged: (val) {
                            _grouppost = val;
                          },
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: "选择的物流方式",
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      children: [
                        const Text(
                          '开始时间:',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 100),
                        DateTimePicker(
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
                              _begintime = val;
                            },
                            onSaved: (val) {
                              _begintime = val!;
                            }),
                      ],
                    ),
                    Wrap(
                      children: [
                        const Text(
                          '结束时间:',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 100),
                        DateTimePicker(
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
                              _endtime = val;
                            },
                            onSaved: (val) {
                              _endtime = val!;
                            }),
                      ],
                    ),
                  ],
                ),
              ),
              for (int j = 0; j < commodityWidget.length; ++j)
                commodityWidget[j],
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 0.5),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular((20.0)),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: TextButton(
                      child: const Text(
                        "添加商品",
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          commodityWidget
                              .add(Row_meta(UniqueKey(), removeMetaRow));
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 0.5),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular((20.0)),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: TextButton(
                      child: const Text(
                        "完成",
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      onPressed: () {
                        _forSubmitted();
                      },
                    ),
                  ),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}

// ignore: camel_case_types, must_be_immutable
class Row_meta extends StatefulWidget {
  Function callback; //删除回调方法作为变量传入
//实现删除组件的功能，key是必要的
  Row_meta(Key key, this.callback) : super(key: key);
  late String _name;
  late String _imageUrl;
  late String _price;
  late String _inventory;
  late String _des;
  bool _miao = false;
  late BuildContext context;

  // ignore: non_constant_identifier_names
  void createCommodityInfo(int GroupId) async {
    int fen = checkEqualNum(_price, context);
    if (fen == -1) {
      return;
    }
    var body = {
      "commodity_name": _name,
      "image_url": _imageUrl,
      "price": fen,
      "inventory": _inventory,
      "des": _des,
      "miao": _miao,
      "group_id": GroupId
    };

    String url = '${Global.host}/CreateCommodity';
    var res=await http.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    checkPermission(saveCommodityImage(_imageUrl,res.body));
  }

  @override
  // ignore: library_private_types_in_public_api
  _RowMetaState createState() => _RowMetaState();
}

class _RowMetaState extends State<Row_meta> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 100),
              TextButton(
                onPressed: () {
                  widget.callback(widget); //回调删除组件的方法，同时传入要删除的组件组件参数（即自身）
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    color: Colors.purple[300],
                  ),
                  child: const Text(
                    '删除',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Wrap(
                children: [
                  const Text(
                    '商品名称:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 100),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    validator: (String? val) {
                      return (val?.length)! >= 1 ? null : '不能为空';
                    },
                    onSaved: (val) {
                      widget._name = val!;
                    },
                    onChanged: (val) {
                      widget._name = val;
                    },
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "此商品名称",
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Wrap(
                children: [
                  const Text(
                    '图片:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 100),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    validator: (String? val) {
                      return (val?.length)! >= 1 ? null : '不能为空';
                    },
                    onSaved: (val) {
                      widget._imageUrl = val!;
                    },
                    onChanged: (val) {
                      widget._imageUrl = val;
                    },
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "此商品的图片链接",
                      //icon: Icon(Icons.add_a_photo),
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 100),
              Wrap(
                children: [
                  const Text(
                    '价格:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 100),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                    ],
                    validator: (String? val) {
                      if ((val?.length)! < 1) {
                        return '不能为空';
                      }
                      var cut = val?.split('.');
                      if ((cut?.length)! > 2) {
                        return '小数点过多';
                      }
                      if (((cut?.length)! == 2) && ((cut?[1].length)! > 2)) {
                        return '最多只能有两位小数';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      widget._price = val!;
                    },
                    onChanged: (val) {
                      widget._price = val;
                    },
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: "此商品单价",
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 100),
              Wrap(
                children: [
                  const Text(
                    '库存:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 100),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    validator: (String? val) {
                      return (val?.length)! >= 1 ? null : '不能为空';
                    },
                    onSaved: (val) {
                      widget._inventory = val!;
                    },
                    onChanged: (val) {
                      widget._inventory = val;
                    },
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: "库存数量",
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 100),
              Wrap(
                children: [
                  const Text(
                    '描述:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 100),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    validator: (String? val) {
                      return (val?.length)! >= 1 ? null : '不能为空';
                    },
                    onSaved: (val) {
                      widget._des = val!;
                    },
                    onChanged: (val) {
                      widget._des = val;
                    },
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "对商品的描述",
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 100),
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
                    value: widget._miao, //当前状态
                    onChanged: (value) {
                      //重新构建页面
                      setState(() {
                        widget._miao = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
