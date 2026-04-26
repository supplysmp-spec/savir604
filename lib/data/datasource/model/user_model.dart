// ignore_for_file: camel_case_types, unnecessary_this, unnecessary_new, prefer_collection_literals

class users_model {
  String? usersEmail;
  String? usersPhone;
  String? usersVerfiycode;
  String? usersApprove;
  String? usersCreat;
  String? usersPassword;
  String? usersId;
  String? usersName;

  users_model(
      {this.usersEmail,
      this.usersPhone,
      this.usersVerfiycode,
      this.usersApprove,
      this.usersCreat,
      this.usersPassword,
      this.usersId,
      this.usersName});

  users_model.fromJson(Map<String, dynamic> json) {
    usersEmail = json['users_email'].toString();
    usersPhone = json['users_phone'].toString();
    usersVerfiycode = json['users_verfiycode'].toString();
    usersApprove = json['users_approve'].toString();
    usersCreat = json['users_creat'].toString();
    usersPassword = json['users_password'].toString();
    usersId = json['users_id'].toString();
    usersName = json['users_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['users_email'] = this.usersEmail;
    data['users_phone'] = this.usersPhone;
    data['users_verfiycode'] = this.usersVerfiycode;
    data['users_approve'] = this.usersApprove;
    data['users_creat'] = this.usersCreat;
    data['users_password'] = this.usersPassword;
    data['users_id'] = this.usersId;
    data['users_name'] = this.usersName;
    return data;
  }
}
