import 'user_model.dart';

class LoginResponse {
  final String status;
  final String? message;
  final User user;
  final String token;

  LoginResponse({
    required this.status,
    this.message,
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      message: json['message'],
      user: User.fromJson(json['data']['user']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': {
        'user': user.toJson(),
        'token': token,
      },
    };
  }

  @override
  String toString() {
    return 'LoginResponse(status: $status, message: $message, user: $user, token: $token)';
  }
}
