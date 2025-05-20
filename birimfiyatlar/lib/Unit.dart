class Unit {
  final int id;
  final String code;
  final String name;
  final String ekapEquivalent;
  final String nationalCode;
  final bool isDeleted;
  final int tenantId;
  final String createUserId;
  final DateTime createdDate;

  Unit({
    required this.id,
    required this.code,
    required this.name,
    required this.ekapEquivalent,
    required this.nationalCode,
    required this.isDeleted,
    required this.tenantId,
    required this.createUserId,
    required this.createdDate,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      ekapEquivalent: json['ekapEquivalent'],
      nationalCode: json['nationalCode'],
      isDeleted: json['isDeleted'],
      tenantId: json['tenantId'],
      createUserId: json['createUserId'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}