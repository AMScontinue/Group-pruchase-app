import 'dart:convert';
import 'package:flutter/material.dart';
import 'common.dart';
import 'FUNCTION.dart';
import 'package:http/http.dart' as http;

class MyHomePageState extends StatelessWidget {
  final dynamic data;

  const MyHomePageState({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyHomePage(data: data);
  }
}

class MyHomePage extends StatefulWidget {
  final dynamic data;

  const MyHomePage({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _MyHomePageState createState() => _MyHomePageState(data: data);
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic data;

  _MyHomePageState({required this.data});

  List<groupInfo> group = [];
  List<List<Commodity>> commodities = [];
  var alldata = [];

  void getAllInfo() async {
    group.clear();
    commodities.clear();
    alldata.clear();
    String url = '${Global.host}/getAllGroupInfo';
    http.Response response = await http.post(Uri.parse(url));
    alldata = jsonDecode(response.body);
    getGroups(group, commodities, alldata);
    setState(() {
      group;
      commodities;
      alldata;
    });
  }

  void tapGroup(int j) async {
    String userId = (data == null ? "0" : data[0].toString());
    String isHead = "0";
    var body = {
      'id': alldata[j + 1][1],
      'user_id': userId,
    };
    String url = '${Global.host}/CheckHead';
    var client = http.Client();
    var response = await client.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    isHead = response.body;
    String tmp = jsonEncode({
      'id': group[j].id,
      'head': isHead,
      'user_id': userId,
      'from_home': "1", //从主页进入
    });
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, 'GroupPurchaseinfo', arguments: tmp)
        .then((value) {
      getAllInfo();
    });
  }

  @override
  void initState() {
    super.initState();
    getAllInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('团购主页'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pushNamed(context, 'Search',arguments: data == null? "0" : data[0].toString()),
            icon: const Icon(Icons.search),
          ),
        ),
        backgroundColor: Colors.grey[200],
        body: ListView(
          children: <Widget>[
            for (int j = 0; j < group.length; j++)
              showGroup(group[j], tapGroup, j),
          ],
        ));
  }
}
