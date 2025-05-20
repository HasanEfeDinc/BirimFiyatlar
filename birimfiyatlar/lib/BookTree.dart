class BookTree {
  final int? id;
  final int? parentId;
  final String? displayName;
  final String? nodeCode;
  final int? nodeKind;
  final bool? hasItems;
  final bool? includePlan;
  final String? path;
  final String? fullCode;
  bool isSelected;

  BookTree({
    this.id,
    this.parentId,
    this.displayName,
    this.nodeCode,
    this.nodeKind,
    this.hasItems,
    this.includePlan,
    this.path,
    this.fullCode,
    this.isSelected = false,
  });

  factory BookTree.fromJson(Map<String, dynamic> json) {
    return BookTree(
      id: json['id'] as int?,
      parentId: json['parentId'] as int?,
      displayName: json['displayName'] as String?,
      nodeCode: json['nodeCode'] as String?,
      nodeKind: json['nodeKind'] as int?,
      hasItems: json['hasItems'] as bool?,
      includePlan: json['includePlan'] as bool?,
      path: json['path'] as String?,
      fullCode: json['fullCode'] as String?,
      isSelected: (json['isSelected'] ?? false) as bool,
    );
  }
}
