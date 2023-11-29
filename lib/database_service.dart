import "dart:convert";
import "dart:io";
import "package:http/http.dart" as http;
import "package:notes/models/user_model.dart";

enum ActionType { add, cat }

// host ipfs daemon on a server and change the host to the server's ip
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  //http://64.227.136.99:5001/ipfs/bafybeiamycmd52xvg6k3nzr6z3n33de6a2teyhquhj4kspdtnvetnkrfim
  Uri _endpoint(ActionType type) {
    return Uri(
        scheme: "http",
        host: "64.227.136.99",
        port: 5001,
        path: "/api/v0/${type.name}");
  }

  Future<String?> addFile(Map<String, dynamic> data) async {
    final tempDir = Directory.systemTemp;
    final randomString =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final File tempFile = File("${tempDir.path}\\$randomString.json");
    await tempFile.writeAsString(jsonEncode(data));

    var multiPartRequest = http.MultipartRequest(
      "POST",
      _endpoint(ActionType.add),
    )..files.add(await http.MultipartFile.fromPath("path", tempFile.path));

    var response = await multiPartRequest.send();

    if (response.statusCode == 200) {
      String responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);
      return json['Hash']; // This is the CID of the uploaded file
    } else {
      throw Exception('Failed to upload to IPFS');
    }
  }

  Future<Map<String, dynamic>?> getData(String cid) async {
    Map<String, String> map = {};
    map["arg"] = cid;

    var request = http.MultipartRequest("POST", _endpoint(ActionType.cat))
      ..fields.addAll(map);
    var res = await request.send();
    if (res.statusCode == 200) {
      var json = jsonDecode(await res.stream.bytesToString());
      return json;
    }
    return null;
  }

  Future<User> getUser(String cid) async {
    Map<String, String> map = {};
    map["arg"] = cid;

    var request = http.MultipartRequest("POST", _endpoint(ActionType.cat))
      ..fields.addAll(map);
    var res = await request.send();
    if (res.statusCode == 200) {
      var json = jsonDecode(await res.stream.bytesToString());
      json['cid'] = cid;
      User user = User.fromJson(json);
      return user;
    }

    return User(name: "Error", cid: cid);
  }
}
