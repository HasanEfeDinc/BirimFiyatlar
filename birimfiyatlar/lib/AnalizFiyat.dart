class AnalizBirimFiyat {
  final int id;
  final int workItemId;
  final double price;
  final double installationPrice;
  final String? effectiveDate;

  AnalizBirimFiyat({
    required this.id,
    required this.workItemId,
    required this.price,
    required this.installationPrice,
    required this.effectiveDate,
  });

  factory AnalizBirimFiyat.fromJson(Map<String, dynamic> json) {
    return AnalizBirimFiyat(
      id: json['id'],
      workItemId: json['workItemId'],
      price: (json['price'] as num).toDouble(),
      installationPrice: (json['installationPrice'] as num).toDouble(),
      effectiveDate: json['effectiveDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workItemId': workItemId,
      'price': price,
      'installationPrice': installationPrice,
      'effectiveDate': effectiveDate,
    };
  }
}