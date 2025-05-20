class Poz {
  final String? fullCode;
  final String? bookCode;
  final String? bookName;
  final String? bookLogoUrl;
  final dynamic parentNode;
  final String? unitName;
  final double? unitPrice;
  final String? nodeTypeText;
  final String? nodeKindText;
  final String? shippingText;
  final String? acquisitionText;
  final dynamic panelType;
  final bool? screenEditable;
  final int? id;
  final int? parentId;
  final String? name;
  final int? nodeType;
  final bool? includePlan;
  final String? nodeCode;
  final int? nodeKind;
  final double? profitRate;
  final int? unitId;
  final String? longDefinition;
  final String? depiction;
  final String? notes;
  final String? keywords;
  final bool? shipping;
  final bool? priceGap;
  final bool? acquisition;
  final double? acquisitionRate;
  final bool? workabilityRaise;
  final double? workabilityRaiseRate;
  final bool? pipeAssembly;
  final double? pipeAssemblyRate;
  final int? pipeAssemblyWorkItemId;
  final DateTime? startEffectiveDate;
  final DateTime? endEffectiveDate;
  bool? isSelected;

  Poz({
    this.fullCode,
    this.bookCode,
    this.bookName,
    this.bookLogoUrl,
    this.parentNode,
    this.unitName,
    this.unitPrice,
    this.nodeTypeText,
    this.nodeKindText,
    this.shippingText,
    this.acquisitionText,
    this.panelType,
    this.screenEditable,
    this.id,
    this.parentId,
    this.name,
    this.nodeType,
    this.includePlan,
    this.nodeCode,
    this.nodeKind,
    this.profitRate,
    this.unitId,
    this.longDefinition,
    this.depiction,
    this.notes,
    this.keywords,
    this.shipping,
    this.priceGap,
    this.acquisition,
    this.acquisitionRate,
    this.workabilityRaise,
    this.workabilityRaiseRate,
    this.pipeAssembly,
    this.pipeAssemblyRate,
    this.pipeAssemblyWorkItemId,
    this.startEffectiveDate,
    this.endEffectiveDate,
    this.isSelected,
  });

  factory Poz.fromJson(Map<String, dynamic> json) {
    return Poz(
      fullCode: json['fullCode'] as String?,
      bookCode: json['bookCode'] as String?,
      bookName: json['bookName'] as String?,
      bookLogoUrl: json['bookLogoUrl'] as String?,
      parentNode: json['parentNode'],
      unitName: json['unitName'] as String?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      nodeTypeText: json['nodeTypeText'] as String?,
      nodeKindText: json['nodeKindText'] as String?,
      shippingText: json['shippingText'] as String?,
      acquisitionText: json['acquisitionText'] as String?,
      panelType: json['panelType'],
      screenEditable: json['screenEditable'] as bool?,
      id: json['id'] as int?,
      parentId: json['parentId'] as int?,
      name: json['name'] as String?,
      nodeType: json['nodeType'] as int?,
      includePlan: json['includePlan'] as bool?,
      nodeCode: json['nodeCode'] as String?,
      nodeKind: json['nodeKind'] as int?,
      profitRate: (json['profitRate'] as num?)?.toDouble(),
      unitId: json['unitId'] as int?,
      longDefinition: json['longDefinition'] as String?,
      depiction: json['depiction'] as String?,
      notes: json['notes'] as String?,
      keywords: json['keywords'] as String?,
      shipping: json['shipping'] as bool?,
      priceGap: json['priceGap'] as bool?,
      acquisition: json['acquisition'] as bool?,
      acquisitionRate: (json['acquisitionRate'] as num?)?.toDouble(),
      workabilityRaise: json['workabilityRaise'] as bool?,
      workabilityRaiseRate: (json['workabilityRaiseRate'] as num?)?.toDouble(),
      pipeAssembly: json['pipeAssembly'] as bool?,
      pipeAssemblyRate: (json['pipeAssemblyRate'] as num?)?.toDouble(),
      pipeAssemblyWorkItemId: json['pipeAssemblyWorkItemId'] as int?,
      startEffectiveDate: _parseDate(json['startEffectiveDate']),
      endEffectiveDate: _parseDate(json['endEffectiveDate']),
      isSelected: json['isSelected'] as bool?,
    );
  }

  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    final dateStr = dateValue.toString();
    if (dateStr.isEmpty || dateStr.startsWith('0001-01-01')) {
      return null;
    }
    return DateTime.tryParse(dateStr);
  }
}
