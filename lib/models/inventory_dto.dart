class InventoryDTO {
  final String? id;
  final String? productId;
  final String? productVarietyId;
  final String? storeId;
  final String? companyId;
  final int? currentStock;
  final int? minStock;
  final int? maxStock;
  final double? averageCost;
  final String? location; // Ubicación física en la tienda
  final DateTime? lastMovementDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InventoryDTO({
    this.id,
    required this.productId,
    this.productVarietyId,
    required this.storeId,
    required this.companyId,
    required this.currentStock,
    this.minStock = 0,
    this.maxStock = 1000,
    this.averageCost,
    this.location,
    this.lastMovementDate,
    this.createdAt,
    this.updatedAt,
  });

  factory InventoryDTO.fromJson(Map<String, dynamic> json) {
    return InventoryDTO(
      id: json['id'] as String?,
      productId: json['productId'] as String?,
      productVarietyId: json['productVarietyId'] as String?,
      storeId: json['storeId'] as String?,
      companyId: json['companyId'] as String?,
      currentStock: json['currentStock'] as int?,
      minStock: json['minStock'] as int? ?? 0,
      maxStock: json['maxStock'] as int? ?? 1000,
      averageCost: (json['averageCost'] as num?)?.toDouble(),
      location: json['location'] as String?,
      lastMovementDate: json['lastMovementDate'] != null 
          ? DateTime.parse(json['lastMovementDate'] as String)
          : null,
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
      'productId': productId,
      'productVarietyId': productVarietyId,
      'storeId': storeId,
      'companyId': companyId,
      'currentStock': currentStock,
      'minStock': minStock,
      'maxStock': maxStock,
      'averageCost': averageCost,
      'location': location,
      'lastMovementDate': lastMovementDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Métodos útiles
  bool get isLowStock => currentStock! <= minStock!;
  bool get isOverStock => currentStock! >= maxStock!;
  bool get isOutOfStock => currentStock == 0;
}