class CollegeModel {
  final String id;
  final String name;
  final String university;
  final String state;
  final String district;

  CollegeModel({
    required this.id,
    required this.name,
    required this.university,
    required this.state,
    required this.district,
  });

  factory CollegeModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CollegeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      university: json['university']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
    );
  }
}