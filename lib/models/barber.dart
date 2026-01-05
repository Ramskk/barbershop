class Barber {
  final int id;
  final String name;

  Barber({required this.id, required this.name});

  factory Barber.fromMap(Map<String, dynamic> m) =>
      Barber(id: m['id'], name: m['name']);
}
