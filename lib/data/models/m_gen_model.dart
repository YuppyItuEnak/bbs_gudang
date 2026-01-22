class MGenModel {
  final String id;
  final String group;
  final String? value1;

  MGenModel({
    required this.id,
    required this.group,
    this.value1,
  });

  factory MGenModel.fromJson(Map<String, dynamic> json) {
    return MGenModel(
      id: json['id'],
      group: json['group'],
      value1: json['value1'],
    );
  }
}
