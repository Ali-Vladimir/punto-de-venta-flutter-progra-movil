class PurchaseDTO {
  final String? id;
  final String? number;
  final String? truckDescription;
  final DateTime? date;
  final String? providerId;
  final String? createdBy;
  final String? observations;
  final double? total;
  final String? status;
  final String? city;
  final String? companyId;
  final String? storeId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseDTO({
    this.id,
    required this.number,
    this.truckDescription,
    required this.date,
    required this.providerId,
    required this.createdBy,
    this.observations,
    required this.total,
    this.status = 'pending',
    this.city,
    required this.companyId,
    this.storeId,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseDTO.fromJson(Map<String, dynamic> json) {
    return PurchaseDTO(
      id: json['id'] as String?,
      number: json['number'] as String?,
      truckDescription: json['truckDescription'] as String?,
      date: json['date'] != null 
          ? DateTime.parse(json['date'] as String)
          : null,
      providerId: json['providerId'] as String?,
      createdBy: json['createdBy'] as String?,
      observations: json['observations'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      city: json['city'] as String?,
      companyId: json['companyId'] as String?,
      storeId: json['storeId'] as String?,
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
      'truckDescription': truckDescription,
      'date': date?.toIso8601String(),
      'providerId': providerId,
      'createdBy': createdBy,
      'observations': observations,
      'total': total,
      'status': status,
      'city': city,
      'companyId': companyId,
      'storeId': storeId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
