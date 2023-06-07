/*
 * @Author: 蔡永康
 * @Date: 2023-06-07 09:50:17
 * @LastEditors: 蔡永康
 * @LastEditTime: 2023-06-07 10:17:34
 * @FilePath: /json_to_dart/lib/util/comm.dart
 * @Description: 
 * 
 * Copyright (c) 2023 by 用户/公司名, All Rights Reserved. 
 */
import 'package:flutter/material.dart';

import '../widget/hover_event_widget.dart';

class CommConst {
  static double textSize = 16;
}

class FieldParserResult {
  String fields;
  List<String> clzs;

  FieldParserResult(this.fields, this.clzs);
}

class FieldParserTextSpanResult {
  TextSpan fields;
  List<TextSpan> clzs;

  FieldParserTextSpanResult(this.fields, this.clzs);
}

TextStyle classNameStyle = const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
TextStyle fieldStyle = const TextStyle(color: Colors.blue, fontWeight: FontWeight.w400);

double midWidth = 180;

EdgeInsets commMargin = const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10);

Widget getTipWidget({String showTip = '提示', required String toastTip, required bool showDown}) {
  Widget space = const SizedBox(width: 2);
  Widget tipText = Row(children: [Text(showTip), space, const Icon(Icons.help, size: 18)]);
  Widget floatWidget = Text(toastTip, style: const TextStyle(fontSize: 14, color: Colors.black));
  floatWidget = Material(child: floatWidget);
  floatWidget = Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 20.0)]),
      child: floatWidget);
  Widget tipWidget = SizedBox(
      width: 50,
      height: 30,
      child: Center(
          child: HoverEventWidget(
        showChild: tipText,
        floatWidget: floatWidget,
        showDown: showDown,
      )));

  return tipWidget;
}
