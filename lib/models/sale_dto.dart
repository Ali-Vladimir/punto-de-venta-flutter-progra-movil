class SaleDTO {
  final String? id;
  final String? number;
  final String? customerId;
  final String? createdBy;
  final String? storeId;
  final String? companyId;
  final double? subtotal;
  final double? tax;
  final double? discount;
  final double? total;
  final String? status;
  final String? paymentMethod;
  final String? notes;
  final DateTime? saleDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SaleDTO({
    this.id,
    required this.number,
    this.customerId,
    required this.createdBy,
    required this.storeId,
    required this.companyId,
    required this.subtotal,
    this.tax = 0.0,
    this.discount = 0.0,
    required this.total,
    this.status = 'completed',
    this.paymentMethod,
    this.notes,
    this.saleDate,
    this.createdAt,
    this.updatedAt,
  });

  factory SaleDTO.fromJson(Map<String, dynamic> json) {
    return SaleDTO(
      id: json['id'] as String?,
      number: json['number'] as String?,
      customerId: json['customerId'] as String?,
      createdBy: json['createdBy'] as String?,
      storeId: json['storeId'] as String?,
      companyId: json['companyId'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'completed',
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
      saleDate: json['saleDate'] != null 
          ? DateTime.parse(json['saleDate'] as String)
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
      'number': number,
      'customerId': customerId,
      'createdBy': createdBy,
      'storeId': storeId,
      'companyId': companyId,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'saleDate': saleDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}