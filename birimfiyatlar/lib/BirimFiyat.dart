class BirimFiyat {
  final int? id;
  final int? workItemId;
  final double? price;
  final double? installationPrice;
  final String? effectiveDate;
  final dynamic workItem;
  final bool? isDeleted;
  final int? tenantId;
  final String? createUserId;
  final String? createdDate;
  final dynamic createUser;
  final dynamic tenant;

  BirimFiyat({
    this.id,
    this.workItemId,
    this.price,
    this.installationPrice,
    this.effectiveDate,
    this.workItem,
    this.isDeleted,
    this.tenantId,
    this.createUserId,
    this.createdDate,
    this.createUser,
    this.tenant,
  });

  factory BirimFiyat.fromJson(Map<String, dynamic> json) {
    return BirimFiyat(
      id: json['id'] as int?,
      workItemId: json['workItemId'] as int?,
      price: (json['price'] as num?)?.toDouble(),
      installationPrice: (json['installationPrice'] as num?)?.toDouble(),
      effectiveDate: json['effectiveDate'] as String?,
      workItem: json['workItem'],
      isDeleted: json['isDeleted'] as bool?,
      tenantId: json['tenantId'] as int?,
      createUserId: json['createUserId'] as String?,
      createdDate: json['createdDate'] as String?,
      createUser: json['createUser'],
      tenant: json['tenant'],
    );
  }
}
