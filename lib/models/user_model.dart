class UserModel {
  final String token;
  final String login;
  final String email;
  final String message;
  final bool isGuest;

  String get name => login;
  String get surname => '';

  const UserModel({
    required this.token,
    required this.login,
    required this.email,
    this.message = '',
    this.isGuest = false,
  });

  String get fullName {
    final value = login.trim();
    return value.isEmpty ? 'Пользователь' : value;
  }

  factory UserModel.fromRegisterJson(
    Map<String, dynamic> json, {
    required String login,
    required String email,
  }) {
    final token = json['token'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('Сервер не вернул token');
    }

    return UserModel(
      token: token.toString(),
      login: login,
      email: email,
      message: (json['message'] ?? '').toString(),
    );
  }

  factory UserModel.fromLoginJson(
    Map<String, dynamic> json, {
    required String email,
  }) {
    final token = json['token'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('Сервер не вернул token');
    }

    return UserModel(
      token: token.toString(),
      login: (json['login'] ?? '').toString(),
      email: email,
      message: (json['message'] ?? '').toString(),
    );
  }

  factory UserModel.guest() {
    return const UserModel(
      token: '',
      login: 'Гость',
      email: '',
      isGuest: true,
    );
  }
}