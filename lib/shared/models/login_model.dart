class LoginModel {
  String name = "";
  String mail = "";
  String password = "";
  late bool keepOn;

  LoginModel(
      {required this.name,
      required this.mail,
      required this.password,
      this.keepOn = false});

  LoginModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    mail = json['mail'];
    password = json['password'];
    keepOn = json['keepOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['mail'] = this.mail;
    data['password'] = this.password;
    data['keepOn'] = this.keepOn;
    return data;
  }

  String toString() {
    return "Name: " +
        this.name +
        "\nE-mail: " +
        this.mail +
        "\nPassword: " +
        this.password;
  }
}
