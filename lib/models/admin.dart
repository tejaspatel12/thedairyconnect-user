class Admin {
  String _username;
  String _password;

  Admin(this._username, this._password);

  Admin.map(dynamic obj) {
    this._username = obj["username"];
    this._password = obj["password"];
  }

  String get username => _username;
  String get password => _password;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["username"] = _username;
    map["password"] = _password;

    return map;
  }
}