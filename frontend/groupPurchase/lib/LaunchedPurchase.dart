import 'package:flutter/material.dart';
import 'common.dart';
import 'FUNCTION.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class LaunchedPurchase extends StatelessWidget {
  const LaunchedPurchase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    var res = jsonDecode(args.toString());
    return Launched(data: res);
  }
}

// ignore: must_be_immutable
class Launched extends StatefulWidget {
  dynamic data;

  Launched({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state, library_private_types_in_public_api
  _Launched createState() => _Launched(data: data);
}

class _Launched extends State<Launched> {
  dynamic data;

  _Launched({required this.data});

  List<groupInfo> group = [];
  List<List<Commodity>> commodities = [];
  var alldata = [];

  void getLaunched() async {
    group.clear();
    commodities.clear();
    alldata.clear();
    var body = {'user_id': data};
    String url = '${Global.host}/GetLaunched';
    var client = http.Client();
    var response = await client.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    alldata = jsonDecode(response.body);
    if (alldata.toString() == "") {
      return;
    }
    getGroups(group, commodities, alldata);
    setState(() {
      group;
      commodities;
      alldata;
      data;
    });
  }

  void tapGroup(int j) async {
    String tmp = jsonEncode({
      'id': group[j].id,
      'head': "1",
      'user_id': data,
      'from_home': "0", //从主页进入
    });
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, 'GroupPurchaseinfo', arguments: tmp)
        .then((value) {
      getLaunched();
    });
  }

  @override
  void initState() {
    super.initState();
    getLaunched();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("已发起团购"),
          centerTitle: true,
        ),
        backgroundColor: Colors.grey[200],
        body: ListView(
          children: <Widget>[
            for (int j = 0; j < group.length; j++)
              showGroup(group[j], tapGroup, j)
          ],
        ));
  }
}
