class SaleItemDTO {
  final String? id;
  final String? saleId;
  final String? productId;
  final String? productVarietyId;
  final double? quantity;
  final double? unitPrice;
  final double? discount;
  final double? subtotal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SaleItemDTO({
    this.id,
    required this.saleId,
    required this.productId,
    this.productVarietyId,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
    this.subtotal,
    this.createdAt,
    this.updatedAt,
  });

  factory SaleItemDTO.fromJson(Map<String, dynamic> json) {
    return SaleItemDTO(
      id: json['id'] as String?,
      saleId: json['saleId'] as String?,
      productId: json['productId'] as String?,
      productVarietyId: json['productVarietyId'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'productVarietyId': productVarietyId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
      'subtotal': subtotal,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
