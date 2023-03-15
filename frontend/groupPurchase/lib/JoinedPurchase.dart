import 'package:flutter/material.dart';
import 'common.dart';
import 'FUNCTION.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class JoinedPurchase extends StatelessWidget {
  const JoinedPurchase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    var res = jsonDecode(args.toString());
    return Joined(data: res);
  }
}

// ignore: must_be_immutable
class Joined extends StatefulWidget {
  dynamic data;

  Joined({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state, library_private_types_in_public_api
  _Joined createState() => _Joined(data: data);
}

class _Joined extends State<Joined> {
  dynamic data;

  _Joined({required this.data});

  List<groupInfo> group = [];
  List<List<Commodity>> commodities = [];
  var alldata = [];

  Future getJoined() async {
    group.clear();
    commodities.clear();
    alldata.clear();
    var body = {'user_id': data};
    String url = '${Global.host}/GetJoined';
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
      'head': "0",
      'user_id': data,
      'from_home': "0", //从主页进入
    });
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, 'GroupPurchaseinfo', arguments: tmp)
        .then((value) {
      getJoined();
    });
  }

  @override
  void initState() {
    super.initState();
    getJoined();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("已参与团购"),
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
