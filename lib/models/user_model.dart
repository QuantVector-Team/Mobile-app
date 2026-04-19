class UserModel {
  final String token;
  final int userId;

  UserModel({required this.token, required this.userId});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(token: json['token'] as String, userId: json['user_id'] as int);
}