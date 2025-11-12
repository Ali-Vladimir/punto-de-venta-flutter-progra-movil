class ProductVarietyDTO {
  final String? id;
  final String? name;
  final String? description;
  final double? price;
  final String? productId;
  final String? sku;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductVarietyDTO({
    this.id,
    required this.name,
    this.description,
    required this.price,
    required this.productId,
    this.sku,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductVarietyDTO.fromJson(Map<String, dynamic> json) {
    return ProductVarietyDTO(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      productId: json['productId'] as String?,
      sku: json['sku'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
      'name': name,
      'description': description,
      'price': price,
      'productId': productId,
      'sku': sku,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
