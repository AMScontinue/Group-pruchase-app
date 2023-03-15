import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'FUNCTION.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RegisterPage(context);
  }
}

class RegisterPage extends StatefulWidget {
  final BuildContext registerContext;

  const RegisterPage(this.registerContext, {Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usr = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pwd1 = TextEditingController();
  TextEditingController pwd2 = TextEditingController();

  GlobalKey k = GlobalKey<FormState>();

  String str = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$";

  void tryRegister() async {
    var body = {
      'user_name': usr.text,
      'password': pwd1.text,
      'email': email.text,
      'image_url':
          'https://img2.baidu.com/it/u=1367512152,228915312&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
    };
    String url = '${Global.host}/NewUser';
    var client = http.Client();
    var response = await client.post(Uri.parse(url),
        body: json.encode(body), headers: {"content-type": "application/json"});
    bool res = true;
    if (response.body == "0") {
      res = false;
    }
    showDialog(
        context: widget.registerContext,
        builder: (_) => AlertDialog(
              title: const Text("提示"),
              content: SingleChildScrollView(
                child: Text(res == true
                    ? "用户'${usr.text}'注册成功"
                    : "用户'${usr.text}'已存在，注册失败"),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      usr.clear();
                      email.clear();
                      pwd1.clear();
                      pwd2.clear();
                      Navigator.of(widget.registerContext).pop();
                      if (res == true) {
                        Navigator.of(widget.registerContext).pop();
                        checkPermission(saveUserImage(
                            'https://img2.baidu.com/it/u=1367512152,228915312&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500',
                            response.body));
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
          title: const Text("注册"),
        ),
        body: SingleChildScrollView(
          child: Form(
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
                  autofocus: true,
                  controller: email,
                  decoration: const InputDecoration(
                      labelText: "邮箱",
                      hintText: "请输入邮箱",
                      prefixIcon: Icon(Icons.email)),
                  validator: (v) {
                    return RegExp(str).hasMatch(v!.trim()) ? null : "邮箱格式有误";
                  },
                ),
                TextFormField(
                  controller: pwd1,
                  decoration: const InputDecoration(
                      labelText: "密码",
                      hintText: "请输入密码",
                      prefixIcon: Icon(Icons.lock)),
                  validator: (v) {
                    return v!.trim().isNotEmpty ? null : "密码不能为空";
                  },
                  obscureText: true,
                ),
                TextFormField(
                  controller: pwd2,
                  decoration: const InputDecoration(
                      labelText: "重复密码",
                      hintText: "请重复密码",
                      prefixIcon: Icon(Icons.lock)),
                  validator: (v) {
                    if (v!.trim().isEmpty) {
                      return "密码不能为空";
                    } else if (pwd1.text != pwd2.text) {
                      return "两次输入的密码必须一致";
                    } else {
                      return null;
                    }
                  },
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: () {
                    if ((k.currentState as FormState).validate()) {
                      tryRegister();
                    }
                  },
                  child: const Text("注册"),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(widget.registerContext).pop();
                      Navigator.pushNamed(widget.registerContext, 'Login');
                    },
                    child: const Text("已有账号？点此前往登录"))
              ],
            ),
          ),
        ));
  }
}
