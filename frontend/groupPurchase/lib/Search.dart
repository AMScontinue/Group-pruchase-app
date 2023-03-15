import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'FUNCTION.dart';
class Search extends StatelessWidget {
  const Search({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    return SearchPage(data: args);
  }
}


class SearchPage extends StatefulWidget {
  dynamic data;

  SearchPage({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api, no_logic_in_create_state
  _Search createState() => _Search(userid: data);
}

class _Search extends State<SearchPage> {
  dynamic userid;
  var searchByGNameClicked = false;
  var searchByHeadClicked = false;
  var inputText = TextEditingController();
  var alldata = [];

  _Search({required this.userid});

  Future trySearch() async {
    var body = {
      'ByHead': searchByHeadClicked == true ? "1" : "0", //1是选中，0是没有选
      'ByGName': searchByGNameClicked == true ? "1" : "0",
      'KeyWord': inputText.text,
    };
    String url = '${Global.host}/SearchGroup';
    var client = http.Client();
    var response = await client.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    alldata = jsonDecode(response.body);
    return alldata;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 40),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 0.5),
            color: Colors.white,
            borderRadius: BorderRadius.circular((20.0)),
          ),
          child: (Column(children: <Widget>[
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: TextField(
                    controller: inputText,
                    maxLines: null,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "搜索",
                      prefixIcon: Icon(Icons.search),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.purple),
                      ),
                    ),
                  ),
                ),
                TextButton(
                    child: Text(
                      "搜索",
                      style: TextStyle(color: Colors.purple, fontSize: 20),
                    ),
                    onPressed: () async {
                      await trySearch();
                      String tmp = jsonEncode({
                        'userid':userid,
                        'alldata': alldata,
                      });
                      Navigator.pushNamed(context, 'SearchResult',
                          arguments: tmp);
                    })
              ],
            ),
            Row(children: <Widget>[
              Checkbox(
                value: searchByGNameClicked,
                onChanged: (value) {
                  setState(() {
                    searchByGNameClicked = value!;
                    if (searchByHeadClicked) searchByHeadClicked = false;
                  });
                },
                // 选中后的颜色
                activeColor: Colors.blue,
                // 选中后对号的颜色
                checkColor: Colors.white,
              ),
              Text("按团购名称搜索")
            ]),
            Row(children: <Widget>[
              Checkbox(
                value: searchByHeadClicked,
                onChanged: (value) {
                  setState(() {
                    searchByHeadClicked = value!;
                    if (searchByGNameClicked) searchByGNameClicked = false;
                  });
                },
                // 选中后的颜色
                activeColor: Colors.blue,
                // 选中后对号的颜色
                checkColor: Colors.white,
              ),
              Text("按团长名称搜索")
            ])
          ])),
        ));
  }
}
