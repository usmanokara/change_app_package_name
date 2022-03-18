import 'dart:io';

class AndroidRenameSteps {
  static const String LIB_PATH_ACTIVITY = 'lib';
  static const String LIB_PATH_ACTIVITY1 = "";

  AndroidRenameSteps();

  List<File> allFiles = [];

  Future<void> printAllPath(Directory directory) async {
    var list = await directory.listSync();
    for (var fileOrDirectory in list) {
      if (fileOrDirectory is File) {
        allFiles.add(fileOrDirectory);
      } else {
        await printAllPath(fileOrDirectory as Directory);
      }
    }
  }

  List<Map<String, dynamic>> keyValueLIst = [];

  Future<void> process() async {
    await printAllPath(Directory(LIB_PATH_ACTIVITY));
    for (var file in allFiles) {
      var string = await file.readAsString();
      //(\)|,| |\()".*"(\)|,|)
      RegExp exp = RegExp(r'".*"');
      var matches = exp.allMatches(string);
      List<Map<String, int>> startEnd = [];

      for (var element in matches.toList()) {
        startEnd.add({"start": element.start, "end": element.end});
      }

      for (int i = startEnd.length - 1; i >= 0; i--) {
        String variableName = "A" + list.length.toString();
        print(string);

        var oldValue = string.substring(
            startEnd[i]["start"] ?? 0, startEnd[i]["end"] ?? 1);

        print(oldValue);

        string = string.replaceRange(
            startEnd[i]["start"] ?? 0, startEnd[i]["end"] ?? 1, variableName);
        print(string);

        for (var exisitngKeys in keyValueLIst) {
          if (oldValue == exisitngKeys["value"]) {
            continue;
          }
        }

        keyValueLIst.add({"data": variableName, "value": oldValue});
      }
      string = "import 'package:change_app_package_name/translation.dart';\n" +
          string;
      await file.writeAsString(string);
      // print(string);
    }

    var newFile = await File("lib/translation.dart").create();
    String newFileData = "";
    keyValueLIst.forEach((element) {
      newFileData += " const String ${element["data"]}=${element["value"]};\n";
    });
    await newFile.writeAsString(newFileData);
    print(list);
    return;
  }
}
