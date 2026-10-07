class User {
  final int id;
  final String role;
  final String name;
  final String email;
  final String password;

  User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      role: json['role'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'name': name,
        'email': email,
        'password': password,
      };
}
