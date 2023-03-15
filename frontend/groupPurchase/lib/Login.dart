import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'FUNCTION.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LoginPage(context);
  }
}

class LoginPage extends StatefulWidget {
  final BuildContext loginContext;

  const LoginPage(this.loginContext, {Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  TextEditingController usr = TextEditingController();
  TextEditingController pwd = TextEditingController();

  GlobalKey k = GlobalKey<FormState>();

  void tryLogin() async {
    String usr_ = usr.text;
    String pwd_ = pwd.text;
    var body = {
      'user_name': usr_,
      'password': pwd_,
    };
    String url = '${Global.host}/CheckUser';
    var client = http.Client();
    var response = await client.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    int res = 0; //成功登录
    if (response.body == "1") {
      res = 1; //用户不存在
    } else if (response.body == "2") {
      res = 2; //密码错误
    }
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('提示'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text(res == 0 ? "用户'${usr.text}'登录成功" : "登录失败"),
                    res == 0
                        ? const Text("")
                        : Text(res == 1 ? "原因：用户'${usr.text}'不存在" : "原因：密码错误"),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      usr.clear();
                      pwd.clear();
                      if (res == 0) {
                        Navigator.of(widget.loginContext).pop();
                        Navigator.of(widget.loginContext).pop(response.body);
                      } else {
                        Navigator.of(widget.loginContext).pop();
                      }
                    },
                    child: const Text("确定")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("登录"),
      ),
      body: Form(
        key: k,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              controller: usr,
              decoration: const InputDecoration(
                  labelText: "用户名",
                  hintText: "请输入用户名",
                  prefixIcon: Icon(Icons.person)),
              validator: (v) {
                return v!.trim().isNotEmpty ? null : "用户名不能为空";
              },
            ),
            TextFormField(
              controller: pwd,
              decoration: const InputDecoration(
                  labelText: "密码",
                  hintText: "请输入密码",
                  prefixIcon: Icon(Icons.lock)),
              validator: (v) {
                return v!.trim().isNotEmpty ? null : "密码不能为空";
              },
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                if ((k.currentState as FormState).validate()) {
                  tryLogin();
                }
              },
              child: const Text("登录"),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(widget.loginContext, 'Register');
                },
                child: const Text("没有账号？点此前往注册"))
          ],
        ),
      ),
    );
  }
}
