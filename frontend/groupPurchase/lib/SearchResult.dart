import 'dart:convert';

import 'common.dart';
import 'FUNCTION.dart';
import 'package:flutter/material.dart';

class SearchResult extends StatelessWidget {
  const SearchResult({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    dynamic data = jsonDecode(args.toString());
    return SearchResultPage(data: data);
  }
}

// ignore: must_be_immutable
class SearchResultPage extends StatefulWidget {
  dynamic data;

  SearchResultPage({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _SearchResultPage createState() => _SearchResultPage(data: data);
}

class _SearchResultPage extends State<SearchResultPage> {
  dynamic data;
  dynamic alldata;
  dynamic userid;
  List<groupInfo> group = [];
  List<List<Commodity>> commodities = [];
  String dropdownValue = '按团购名称排序(a-z）';
  final List<String> items = <String>['按团购名称排序(a-z）', '按开始时间排序(新到旧）'];

  _SearchResultPage({required this.data});

  void empty() {}

  void tapGroup(int j) async {
    String tmp = jsonEncode({
      'id': group[j].id,
      'head': "0",
      'user_id': userid,
      'from_home': "1", //从主页进入
    });
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, 'GroupPurchaseinfo', arguments: tmp);
  }

  @override
  void initState() {
    super.initState();
    userid=data["userid"];
    alldata=data["alldata"];
    getGroups(group,commodities,alldata);
    group.sort((b, a) => (b.name).compareTo(a.name));//按照团购名称排序
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('搜索结果'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        backgroundColor: Colors.grey[200],
        body: Column(children: [
          DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 8,
            style: TextStyle(fontSize: 15, color: Colors.deepPurple),
            iconEnabledColor: Colors.red,
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
              if (dropdownValue == "按团购名称排序(a-z）")
                group.sort((b, a) => (b.name).compareTo(a.name));
              if (dropdownValue == "按开始时间排序(新到旧）")
                group.sort((a, b) => (b.begin_time).compareTo(a.begin_time));
            },
            items: <String>['按团购名称排序(a-z）', '按开始时间排序(新到旧）']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
              child: ListView(
            children: <Widget>[
              for (int i = 0; i < group.length; i++)
                showGroup(group[i], tapGroup, i)
            ],
          ))
        ]));
  }
}
