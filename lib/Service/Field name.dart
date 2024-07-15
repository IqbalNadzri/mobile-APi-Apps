class FieldName{
  final String FieldnameNumber;

  FieldName({required this.FieldnameNumber});

  factory FieldName.fromJson(Map<String, dynamic> json) {
    return FieldName(FieldnameNumber: json['field_name']);
  }
}