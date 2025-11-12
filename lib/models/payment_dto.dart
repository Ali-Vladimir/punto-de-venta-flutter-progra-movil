class PaymentDTO {
  final String? id;
  final String? method;
  final String? status;
  final double? amount;
  final String? type;
  final String? customerId;
  final String? providerId;
  final String? saleId;
  final String? purchaseId;
  final String? createdBy;
  final String? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentDTO({
    this.id,
    required this.method,
    this.status = 'pending',
    required this.amount,
    required this.type,
    this.customerId,
    this.providerId,
    this.saleId,
    this.purchaseId,
    required this.createdBy,
    required this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentDTO.fromJson(Map<String, dynamic> json) {
    return PaymentDTO(
      id: json['id'] as String?,
      method: json['method'] as String?,
      status: json['status'] as String? ?? 'pending',
      amount: (json['amount'] as num?)?.toDouble(),
      type: json['type'] as String?,
      customerId: json['customerId'] as String?,
      providerId: json['providerId'] as String?,
      saleId: json['saleId'] as String?,
      purchaseId: json['purchaseId'] as String?,
      createdBy: json['createdBy'] as String?,
      companyId: json['companyId'] as String?,
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
      'method': method,
      'status': status,
      'amount': amount,
      'type': type,
      'customerId': customerId,
      'providerId': providerId,
      'saleId': saleId,
      'purchaseId': purchaseId,
      'createdBy': createdBy,
      'companyId': companyId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
