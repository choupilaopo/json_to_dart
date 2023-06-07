/*
 * @Author: 蔡永康
 * @Date: 2022-09-06 01:07:34
 * @LastEditors: 蔡永康
 * @LastEditTime: 2023-06-06 17:13:51
 * @FilePath: /json_util_desktop-main/widget/new_page.dart
 * @Description: 
 * 
 * Copyright (c) 2023 by 用户/公司名, All Rights Reserved. 
 */
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'window_top.dart';

class NewPage extends StatelessWidget {
  const NewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: Scaffold(
        body: WindowBorder(
            color: Colors.blueGrey,
            width: 2,
            child: Column(children: [
              const WindowTopBox(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('返回'),
              )
            ])),
      ),
    ));
  }
}
