class PurchaseItemDTO {
  final String? id;
  final String? purchaseId;
  final String? name;
  final int? quantity;
  final String? unit;
  final double? price;
  final double? subtotal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseItemDTO({
    this.id,
    required this.purchaseId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    this.subtotal,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseItemDTO.fromJson(Map<String, dynamic> json) {
    return PurchaseItemDTO(
      id: json['id'] as String?,
      purchaseId: json['purchaseId'] as String?,
      name: json['name'] as String?,
      quantity: json['quantity'] as int?,
      unit: json['unit'] as String?,
      price: (json['price'] as num?)?.toDouble(),
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
      'purchaseId': purchaseId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'subtotal': subtotal,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
