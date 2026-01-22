class User {
  final String id;
  final String? nik;
  final String? name;
  final String username;
  final String? password;
  final String? desc;
  final String? fUserType;
  final bool? status;
  final bool? userMobile;
  final List<UserDetail> userDetails;

  User({
    required this.id,
    this.nik,
    this.name,
    required this.username,
    this.password,
    this.desc,
    this.fUserType,
    this.status,
    this.userMobile,
    this.userDetails = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nik: json['nik'],
      name: json['name'],
      username: json['username'] ?? '',
      password: json['password'],
      desc: json['desc'],
      fUserType: json['f_user_type'],
      status: json['status'],
      userMobile: json['user_mobile'],
      userDetails:
          (json['user_details'] as List<dynamic>?)
              ?.map((e) => UserDetail.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nik': nik,
      'name': name,
      'username': username,
      'password': password,
      'desc': desc,
      'f_user_type': fUserType,
      'status': status,
      'user_mobile': userMobile,
      'user_details': userDetails.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'User(username: $username, name: $name, userMobile: $userMobile)';
  }
}

class UserDetail {
  final String? fUserDefault;
  final String? fResponsibility;
  final bool? isPrimary;
  final bool? status;

  UserDetail({
    this.fUserDefault,
    this.fResponsibility,
    this.isPrimary,
    this.status,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      fUserDefault: json['f_user_default'],
      fResponsibility: json['f_responsibility'],
      isPrimary: json['is_primary'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'f_user_default': fUserDefault,
      'f_responsibility': fResponsibility,
      'is_primary': isPrimary,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'UserDetail(primary: $isPrimary, status: $status)';
  }
}
