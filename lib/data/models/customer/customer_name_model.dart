class CustomerSimpleModel {
  final String id;
  final String name;
  final String? segment;

  CustomerSimpleModel({required this.id, required this.name, this.segment});

  factory CustomerSimpleModel.fromJson(Map<String, dynamic> json) {
    String? segmentValue;
    if (json['customerGroup'] != null &&
        json['customerGroup']['customerGroupSegment'] != null) {
      segmentValue = json['customerGroup']['customerGroupSegment']['value1'];
    }
    return CustomerSimpleModel(
      id: json['id'],
      name: json['name'],
      segment: segmentValue,
    );
  }
}
