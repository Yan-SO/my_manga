class TegsModel {
  final int? id;
  final String tegName;
  final int children;

  TegsModel({
    this.id,
    required this.tegName,
    required this.children,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tegName': tegName,
      'children': children,
    };
  }

  factory TegsModel.fromJson(Map<String, dynamic> json) {
    return TegsModel(
      id: json['id'],
      tegName: json['tegName'],
      children: json['children'],
    );
  }
}
