class AnalizPoz {
  final String? analysisItemFullCode;
  final int? unitId;
  final double? totalPrice;
  final bool? hasAnalysis;
  final double? profitRate;
  final int? id;
  final int? workItemId;
  final int? orderIndex;
  final int? analysisItemId;
  final int? transportFormulId;
  final String? definition;
  final double? price;
  final String? description;
  final dynamic procedure;
  final String? procedureDefinition;
  final dynamic procedurePriceTypeId;
  final double? quantity;
  final dynamic formulData;
  final dynamic relatedWorkItemAnalysisIds;
  final double? installationPrice;
  final double? materialCost;
  final int? analysisKindId;
  final int? analysisTypeId;

  AnalizPoz({
    this.analysisItemFullCode,
    this.unitId,
    this.totalPrice,
    this.hasAnalysis,
    this.profitRate,
    this.id,
    this.workItemId,
    this.orderIndex,
    this.analysisItemId,
    this.transportFormulId,
    this.definition,
    this.price,
    this.description,
    this.procedure,
    this.procedureDefinition,
    this.procedurePriceTypeId,
    this.quantity,
    this.formulData,
    this.relatedWorkItemAnalysisIds,
    this.installationPrice,
    this.materialCost,
    this.analysisKindId,
    this.analysisTypeId,
  });

  factory AnalizPoz.fromJson(Map<String, dynamic> json) {
    return AnalizPoz(
      analysisItemFullCode: json['analysisItemFullCode'] as String?,
      unitId: json['unitId'] as int?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      hasAnalysis: json['hasAnalysis'] as bool?,
      profitRate: (json['profitRate'] as num?)?.toDouble(),
      id: json['id'] as int?,
      workItemId: json['workItemId'] as int?,
      orderIndex: json['orderIndex'] as int?,
      analysisItemId: json['analysisItemId'] as int?,
      transportFormulId: json['transportFormulId'] as int?,
      definition: json['definition'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      description: json['description'] as String?,
      procedure: json['procedure'],
      procedureDefinition: json['procedureDefinition'] as String?,
      procedurePriceTypeId: json['procedurePriceTypeId'],
      quantity: (json['quantity'] as num?)?.toDouble(),
      formulData: json['formulData'],
      relatedWorkItemAnalysisIds: json['relatedWorkItemAnalysisIds'],
      installationPrice: (json['installationPrice'] as num?)?.toDouble(),
      materialCost: (json['materialCost'] as num?)?.toDouble(),
      analysisKindId: json['analysisKindId'] as int?,
      analysisTypeId: json['analysisTypeId'] as int?,
    );
  }
}
