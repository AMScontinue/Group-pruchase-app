import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'common.dart';

class Global {
  //static String host = "http://10.0.2.2:8080";
  //static String host = "http://192.168.0.55:8080";
  static String host = "http://123.60.70.121:8080";

  // static String host = "http://192.168.43.143:8080";
  static String picture = "storage/emulated/0/Pictures";
}

String buildExtraInfo(Commodity x) {
  // ignore: non_constant_identifier_names
  String? Str = "";
  if (x.miao) {
    Str = "可秒杀";
  } else if (x.number == 0) {
    Str = "已售罄";
  } else {
    Str = "库存${x.number}";
  }
  Str = "   $Str";
  return Str;
}

Widget te(int x) {
  if (x < 3) {
    return Wrap(
      children: const [
        Text('无人参与，呜呜呜', style: TextStyle(fontSize: 15, color: Colors.red)),
      ],
    );
  } else {
    return Wrap(
      children: const [
        Text('人数爆满，欲购从速', style: TextStyle(fontSize: 15, color: Colors.red)),
      ],
    );
  }
}

Widget showGroup(groupInfo group, Function(int) tap, int j) {
  return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.5),
          color: Colors.white,
          borderRadius: BorderRadius.circular((20.0)),
        ),
        margin: const EdgeInsets.all(15),
        child: Container(
          margin: const EdgeInsets.all(3),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Column(
              children: <Widget>[
                Wrap(children: [
                  Text(group.name, style: const TextStyle(fontSize: 30)),
                ]),
                // Wrap(
                //   children: [
                //     Text('${group.participants}人已参与',
                //         style:
                //             const TextStyle(fontSize: 27, color: Colors.red)),
                //   ],
                // ),
                te(group.participants),
                for (int i = 0; i < group.commodity.length; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flex(
                        mainAxisSize: MainAxisSize.min,
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Image.file(
                                File(
                                    "${Global.picture}/commodity-${group.commodity[i].cid}.jpg"),
                                width: 125,
                                height: 125),
                          ),
                          Flexible(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Wrap(children: [
                                  Text(group.commodity[i].name,
                                      style: const TextStyle(fontSize: 30)),
                                ]),
                                Wrap(
                                  children: [
                                    Text(
                                        '￥${((group.commodity[i].price) / 100.0)}',
                                        style: const TextStyle(
                                            fontSize: 27, color: Colors.brown)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Wrap(
                              children: [
                                Text(buildExtraInfo(group.commodity[i]),
                                    style: const TextStyle(
                                        fontSize: 27, color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        tap(j);
      });
}

void getGroups(
    List<groupInfo> group, List<List<Commodity>> commodities, var alldata) {
  for (int i = 1; i <= int.parse(alldata[0][0]); ++i) {
    List<Commodity> commodity = [];
    for (int j = 0; j < int.parse(alldata[i][0]); ++j) {
      int offset = 7 * j;
      bool tmp;
      if (alldata[i][16 + offset] == "1") {
        tmp = true;
      } else {
        tmp = false;
      }
      commodity.add(Commodity(
          cid: int.parse(alldata[i][10 + offset]),
          name: alldata[i][11 + offset],
          imageUrl: alldata[i][13 + offset],
          description: alldata[i][12 + offset],
          price: int.parse(alldata[i][15 + offset]),
          number: int.parse(alldata[i][14 + offset]),
          miao: tmp));
    }
    commodities.add(commodity);
    group.add(groupInfo(
        id: int.parse(alldata[i][1]),
        name: alldata[i][2],
        description: alldata[i][3],
        begin_time: alldata[i][7],
        end_time: alldata[i][8],
        post: alldata[i][4],
        participants: int.parse(alldata[i][5]),
        commodity: commodities[i - 1],
        link: alldata[i][9]));
  }
}

int checkEqualInteger(String str, BuildContext context) {
  if (str == "") return -1;
  int amount = int.parse(str);
  return amount;
}

int checkEqualNum(String str, BuildContext context) {
  if (str == "") {
    return -1;
  }
  dynamic m = str.split('.');
  if (m.length > 2 || (m.length == 2 && m[1].length > 2)) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text("提示"),
                content: Text(m.length > 2 ? "小数点过多" : "最多只能有两位小数"),
                actions: [
                  ElevatedButton(
                    child: const Text("确定"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]));
    return -1;
  }
  if (m[0] == "") {
    str = "0$str";
  }
  double yuan = double.parse(str);
  int fen = (yuan * 100).floor();
  return fen;
}

Future<bool> requestPermission() async {
  late PermissionStatus status;
  if (Platform.isIOS) {
    status = await Permission.photosAddOnly.request();
  } else {
    status = await Permission.storage.request();
  }
  if (status != PermissionStatus.granted) {
    print("no");
  } else {
    return true;
  }
  return false;
}

checkPermission(Future<dynamic> fun) async {
  bool mark = await requestPermission();
  mark ? fun : null;
}

saveUserImage(String url, String uid) async {
  var res =
      await Dio().get(url, options: Options(responseType: ResponseType.bytes));
  String picName = "user-$uid";
  await ImageGallerySaver.saveImage(Uint8List.fromList(res.data),
      quality: 100, name: picName);
}

saveCommodityImage(String url, String cid) async {
  var res =
      await Dio().get(url, options: Options(responseType: ResponseType.bytes));
  String picName = "commodity-$cid";
  await ImageGallerySaver.saveImage(Uint8List.fromList(res.data),
      quality: 100, name: picName);
}
