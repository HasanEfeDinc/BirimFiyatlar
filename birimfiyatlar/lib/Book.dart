class Book {
  final String? organisationNames;
  final int? id;
  final String? logoUrl;
  final int? scopeId;
  final int? bookTypeId;
  final String? organisationIds;
  final String? code;
  final String? definition;
  final DateTime? releaseDate;
  final bool? isActive;
  bool? isSelected;

  Book({
    this.organisationNames,
    this.id,
    this.logoUrl,
    this.scopeId,
    this.bookTypeId,
    this.organisationIds,
    this.code,
    this.definition,
    this.releaseDate,
    this.isActive,
    this.isSelected,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      organisationNames: json['organisationNames'] as String?,
      id: json['id'] as int?,
      logoUrl: json['logoUrl'] as String?,
      scopeId: json['scopeId'] as int?,
      bookTypeId: json['bookTypeId'] as int?,
      organisationIds: json['organisationIds'] as String?,
      code: json['code'] as String?,
      definition: json['definition'] as String?,
      releaseDate: (json['releaseDate'] == null) ? null : DateTime.parse(json['releaseDate'] as String),
      isActive: json['isActive'] as bool?,
      isSelected: json['isSelected'] as bool?,
    );
  }
}