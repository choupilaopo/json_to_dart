import 'package:flutter/cupertino.dart';
import 'package:ui_package/ui_package.dart';

import '../widget/dart_output_area.dart';
import 'comm.dart';
import 'string_extension_json.dart';

//生成工具
class MapToDartUtil {
  static String trans(Map map, {required String name}) {
    StringBuffer sb = StringBuffer();
    String className = "${name}Model";
    try {
      // 类头
      sb.writeln('class $className {\n');

      // 解析属性时，有可能解析出新的bean，所以这里要想办法把内部的新class传递到最外界
      // 成员属性区

      FieldParserResult fieldParserResult = _fieldArea(map, name);

      sb.writeln(fieldParserResult.fields);

      // 构造函数区
      sb.writeln(_constructorFunctionArea(map, className));

      // fromJson函数
      sb.writeln(_fromJsonFunctionArea(map, name));

      // toJson函数区
      sb.writeln(_toJsonFunctionArea(map));

      // decode函数
      sb.writeln(_decodeFunctionArea(map, className));

      sb.writeln('}\n\n');

      for (var e in fieldParserResult.clzs) {
        sb.writeln(e);
      }
    } catch (e) {
      rethrow;
    }

    return sb.toString();
  }

  /// 判定key是否合法，
  /// 返回值，true 合法 ，false非法
  static bool _judgeIncorrectKey(dynamic key) {
    // 1. 必须是非空字符串
    if (key.runtimeType != String) {
      debugPrint('key $key 不是非空字符串，判定非法');
      return false;
    }

    // 2. 以字母开头, 3. 只能由字母，数字，下划线组成
    String temp = key as String;
    if (!RegExp('^[a-zA-Z][a-zA-Z0-9_]*\$').hasMatch(temp)) {
      debugPrint('key $key 不符合 字母开头并且只能由字母，数字，下划线组成，判定非法');
      return false;
    }

    return true;
  }

  /// 检查一个list的内容是否合法
  static dynamic getListItemType(List list) {
    if (list.isEmpty) {
      return Null;
    }

    if (list.length == 1) {
      return list[0].runtimeType;
    }

    List runtimeTypeList = list.map((e) => e.runtimeType).toList();
    dynamic current = list[0].runtimeType;

    for (var i = 1; i < runtimeTypeList.length; i++) {
      if (current != runtimeTypeList[i]) {
        current = dynamic;
        break;
      }
    }
    return current;
  }

  static FieldParserResult _fieldArea(Map map, String name) {
    StringBuffer sb = StringBuffer();

    List<String> clzs = [];

    List keyList = map.keys.toList();
    for (var key in keyList) {
      dynamic value = map[key];

      // 先排除异常情况
      // 如果key不是非空字符串，或者它不是以字母开头由字母和数字构成，则判定key格式错误
      if (!_judgeIncorrectKey(key)) {
        throw '不合法的key $key'; // 如果是非法，那就抛出异常
      } else if (value is Map) {
        if (value.isEmpty) {
          sb.writeln('''
${_baseSpaces}Map? $key;''');
        } else {
          // 1. 判断是否是字母开头，如果不是，则
          // 2. 再把首字母转成大写
          String keyCapitalize = (key as String).capitalize();
          // 则应该按照一个对象来设置属性，对象类名要转化首字母大小写，如果是不规范的key，则认定为转化失败
          sb.writeln('''
$_baseSpaces$keyCapitalize? $key;''');
          // map和list的情况，有可能需要重新构建出一个新的class

          // 并且取出map的值，然后将它按照一个新的 map来构建一个class
          clzs.add(trans(value, name: keyCapitalize));
        }
      } else if (value is List) {
        if (value.isEmpty) {
          sb.writeln('''
${_baseSpaces}List? $key;''');
        } else {
          dynamic listItemType = getListItemType(value);
          // 如果是 map对象，那就把这个对象命名为 key的首字母大写变换形态
          if ('$listItemType'.contains('Map')) {
            listItemType = "$name${(key as String).capitalize()}";
            var firstItem = (value)[0];
            clzs.add(trans(firstItem as Map, name: listItemType));
            listItemType = "${listItemType}Model";
          }
          sb.writeln('''
${_baseSpaces}List<$listItemType>? $key;''');
        }
      } else if (value is String) {
        sb.writeln('''
${_baseSpaces}String? $key;''');
      } else if (value is bool) {
        sb.writeln('''
${_baseSpaces}bool? $key;''');
      } else if (value is double) {
        sb.writeln('''
${_baseSpaces}double? $key;''');
      } else if (value is int) {
        sb.writeln('''
${_baseSpaces}int? $key;''');
      } else {
        sb.writeln('''
${_baseSpaces}dynamic $key;''');
      }
    }

    return FieldParserResult(sb.toString(), clzs);
  }

  static const String _baseSpaces = '  ';

  static String _constructorFunctionArea(Map map, String className) {
    StringBuffer sb = StringBuffer();

    sb.writeln('$_baseSpaces$className({');

    // 中间对属性进行遍历
    List<String> keyStrList = map.keys.toList().map((e) => '$e').toList();
    for (var e in keyStrList) {
      sb.writeln('$_baseSpaces  $e,');
    }

    sb.writeln('$_baseSpaces});');

    return sb.toString();
  }

  static String _fromJsonFunctionArea(Map map, String name) {
    StringBuffer sb = StringBuffer();
    sb.writeln('$_baseSpaces${name}Model.fromJson(Map<String, dynamic> json) {');
    map.keys.toList().forEach((key) {
      // 获得value的类型
      var value = map[key];

      if (value is Map) {
        if (value.isEmpty) {
          sb.writeln('$_baseSpaces  $key = json[\'$key\'];');
        } else {
          String keyCapitalize = (key as String).capitalize();
          sb.writeln(
              '$_baseSpaces  $key = json[\'$key\'] != null ? $name${keyCapitalize}Model.fromJson(json[\'map\']) : null;');
        }
      } else if (value is List) {
        if (value.isEmpty) {
          sb.writeln('$_baseSpaces  $key = json[\'$key\'];');
        } else {
          var type = getListItemType(value);
          if ('$type'.contains('Map')) {
            type = 'Map<String, dynamic>';
            String keyCapitalize = (key as String).capitalize();
            sb.writeln(''' 
    if (json['$key'] is List) {
      $key = json["$key"] == null
       ? null 
       : (json["$key"] as List).map((e) => $name${keyCapitalize}Model.fromJson(e)).toList();
    }''');
          } else {
            sb.writeln('$_baseSpaces  $key = json[\'$key\'].cast<$type>();');
          }
        }
      } else {
        if (value != null) {
          if (value is String) {
            sb.writeln(''' 
    if (json['$key'] is String) {
      $key = json["$key"];
    }''');
          } else if (value is bool) {
            sb.writeln(''' 
    if (json['$key'] is bool) {
      $key = json["$key"];
    }''');
          } else if (value is double) {
            sb.writeln(''' 
    if (json['$key'] is double) {
      $key = json["$key"];
    }''');
          } else if (value is int) {
            sb.writeln(''' 
    if (json['$key'] is int) {
      $key = json["$key"];
    }''');
          }
        } else {
          sb.writeln('$_baseSpaces  $key = json[\'$key\'];');
        }
      }
    });

    sb.writeln('$_baseSpaces}');
    return sb.toString();
  }

  static String _toJsonFunctionArea(Map map) {
    StringBuffer sb = StringBuffer();
    sb.writeln('${_baseSpaces}Map<String, dynamic> toJson() {');

    sb.writeln('$_baseSpaces  final Map<String, dynamic> data = <String, dynamic>{};');

    map.keys.toList().forEach((key) {
      // 获得value的类型
      var value = map[key];

      if (value is Map) {
        if (value.isEmpty) {
          sb.writeln('$_baseSpaces  data[\'$key\'] = $key;');
        } else {
          sb.writeln('''
$_baseSpaces  if ($key != null) {
$_baseSpaces      data['$key'] = $key!.toJson();
$_baseSpaces  }
        ''');
        }
      } else if (value is List) {
        sb.writeln('''
        if ($key != null) {
          data['$key'] = $key!.map((v) => v.toJson()).toList();
        }
        ''');
      } else {
        sb.writeln('$_baseSpaces  data[\'$key\'] = $key;');
      }
    });

    sb.writeln('$_baseSpaces  return data;');

    sb.writeln('$_baseSpaces}');
    return sb.toString();
  }

  static String _decodeFunctionArea(Map map, String className) {
    StringBuffer sb = StringBuffer();

    sb.writeln('''
    static $className decode(Map<String, dynamic> json) {
     return $className.fromJson(json);
    }
    ''');

    return sb.toString();
  }
}
