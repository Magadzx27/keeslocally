class LieEntry {
  int id; // Unique identifier for the LieEntry
  String name;
  List<String> dates = [];
  List<String> lieDetailsList = [];

  LieEntry({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dates': dates,
      'lieDetailsList': lieDetailsList,
    };
  }

  factory LieEntry.fromJson(Map<String, dynamic> json) {
    return LieEntry(
      id: json['id'],
      name: json['name'],
    );
  }
}
