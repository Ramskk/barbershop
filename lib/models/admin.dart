class Admin {
  final int? id;
  final String username;
  final String password;

  Admin({this.id, required this.username, required this.password});

  factory Admin.fromMap(Map<String, dynamic> m) =>
      Admin(id: m['id'], username: m['username'], password: m['password']);
}
