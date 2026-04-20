class UserModel {
  final String token;
  final String name;
  final String surname;
  final String email;
  final String message;
  final bool isGuest;

  const UserModel({
    required this.token,
    required this.name,
    required this.surname,
    required this.email,
    this.message = '',
    this.isGuest = false,
  });

  String get fullName {
    final value = '${name.trim()} ${surname.trim()}'.trim();
    return value.isEmpty ? 'Пользователь' : value;
  }

  factory UserModel.fromRegisterJson(
    Map<String, dynamic> json, {
    required String name,
    required String surname,
    required String email,
  }) {
    final token = json['token'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('Сервер не вернул token');
    }

    return UserModel(
      token: token.toString(),
      name: name,
      surname: surname,
      email: email,
      message: (json['message'] ?? '').toString(),
    );
  }

  factory UserModel.fromLoginJson(
    Map<String, dynamic> json, {
    required String email,
    String surname = '',
  }) {
    final token = json['token'];

    if (token == null || token.toString().isEmpty) {
      throw Exception('Сервер не вернул token');
    }

    return UserModel(
      token: token.toString(),
      name: (json['name'] ?? '').toString(),
      surname: surname,
      email: email,
      message: (json['message'] ?? '').toString(),
    );
  }

  factory UserModel.guest() {
    return const UserModel(
      token: '',
      name: 'Гость',
      surname: '',
      email: '',
      isGuest: true,
    );
  }
}