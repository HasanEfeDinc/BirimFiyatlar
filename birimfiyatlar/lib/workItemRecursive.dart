import 'AnalizFiyat.dart';
import 'AnalizPoz.dart';

class WorkItemRecursive {
  final List<AnalizBirimFiyat>? workItemPrices;
  final List<AnalizPoz>? workItemAnalysis;
  final int? id;
  final int? parentId;
  final int? bookId;
  final bool? includePlan;
  final String? nTree;
  final String? fullCode;
  final String? nodeCode;
  final String? name;
  final int? nodeKind;
  final int? nodeType;
  final int? unitId;
  final double? profitRate;
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
  final String? startEffectiveDate;
  final String? endEffectiveDate;

  WorkItemRecursive({
    this.workItemPrices,
    this.workItemAnalysis,
    this.id,
    this.parentId,
    this.bookId,
    this.includePlan,
    this.nTree,
    this.fullCode,
    this.nodeCode,
    this.name,
    this.nodeKind,
    this.nodeType,
    this.unitId,
    this.profitRate,
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
  });

  factory WorkItemRecursive.fromJson(Map<String, dynamic> json) {
    return WorkItemRecursive(
      workItemPrices: (json['workItemPrices'] as List<dynamic>?)
          ?.map((e) => AnalizBirimFiyat.fromJson(e as Map<String, dynamic>))
          .toList(),
      workItemAnalysis: (json['workItemAnalysis'] as List<dynamic>?)
          ?.map((e) => AnalizPoz.fromJson(e as Map<String, dynamic>))
          .toList(),

      id: json['id'] as int?,
      parentId: json['parentId'] as int?,
      bookId: json['bookId'] as int?,
      includePlan: json['includePlan'] as bool?,
      nTree: json['nTree'] as String?,
      fullCode: json['fullCode'] as String?,
      nodeCode: json['nodeCode'] as String?,
      name: json['name'] as String?,
      nodeKind: json['nodeKind'] as int?,
      nodeType: json['nodeType'] as int?,
      unitId: json['unitId'] as int?,
      profitRate: (json['profitRate'] as num?)?.toDouble(),
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
      startEffectiveDate: json['startEffectiveDate'] as String?,
      endEffectiveDate: json['endEffectiveDate'] as String?,
    );
  }

}
