class UserModel {
  final String token;

  UserModel({
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('Сервер не вернул token');
    }

    return UserModel(
      token: token.toString(),
    );
  }
}