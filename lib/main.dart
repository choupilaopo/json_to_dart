/*
 * @Author: 蔡永康
 * @Date: 2023-06-06 16:29:19
 * @LastEditors: 蔡永康
 * @LastEditTime: 2023-06-07 09:56:15
 * @FilePath: /json_to_dart/lib/main.dart
 * @Description: 
 * 
 * Copyright (c) 2023 by 用户/公司名, All Rights Reserved. 
 */
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:ui_package/ui_package.dart';

import 'widget/main_page.dart';

void main() {
  Application.run();
}

class Application {
  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    initApplication(() {
      runApp(const MyApp());
      doWhenWindowReady(() {
        var win = appWindow;
        const initialSize = Size(960, 640);
        win.minSize = initialSize;
        // win.maxSize = initialSize;
        // win.size = initialSize;
        win.title = "json to dart";
        win.show();
      });
      
    });
  }

  static Future<void> initApplication(VoidCallback handle) async {
    //所有三方库的初始化都在这里加载
    await SpUtil.getInstance();
    // var loginModel = SpUtil.getObj("loginModel", (v) => LoginModel.fromJson(v as Map<String, dynamic>));
    // GlobalSource.TOKEN = loginModel?.token ?? "";

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    GlobalSource.APP_VERSION = packageInfo.version;
    handle();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToastUtil.init(RefreshConfiguration(
        headerBuilder: () => const WaterDropHeader(),
        footerBuilder: () => const ClassicFooter(),
        headerTriggerDistance: kp(50),
        springDescription: const SpringDescription(mass: 1.9, stiffness: 170, damping: 16),
        maxOverScrollExtent: 100,
        maxUnderScrollExtent: 0,
        enableScrollWhenRefreshCompleted: true,
        enableLoadingWhenFailed: true,
        hideFooterWhenNotFull: false,
        enableBallisticLoad: true,
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            RefreshLocalizations.delegate
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) {
            return locale;
          },
          builder: EasyLoading.init(),
          debugShowCheckedModeBanner: false,
          theme: mDefaultTheme,
          title: "json to dart",
          navigatorKey: GlobalSource.NAVIGATOR_KET,
          home: const MainPage(),
        )));
  }
}
