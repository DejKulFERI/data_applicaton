class User {
  String id;
  String username;
  String email;
  String password;
  String faceImagePath;
  String faceFeaturesPath;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.faceImagePath,
    required this.faceFeaturesPath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'] ?? '',
      faceImagePath: json['faceImagePath'] ?? '',
      faceFeaturesPath: json['faceFeaturesPath'] ?? '',
    );
  }
}
