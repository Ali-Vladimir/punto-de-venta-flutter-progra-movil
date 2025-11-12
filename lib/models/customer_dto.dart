class CustomerDTO {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxId; // RFC, NIT, etc.
  final double? creditLimit;
  final double? currentDebt;
  final String? customerType; // 'individual', 'business'
  final String? companyId;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerDTO({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.taxId,
    this.creditLimit = 0.0,
    this.currentDebt = 0.0,
    this.customerType = 'individual',
    required this.companyId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerDTO.fromJson(Map<String, dynamic> json) {
    return CustomerDTO(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      taxId: json['taxId'] as String?,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      currentDebt: (json['currentDebt'] as num?)?.toDouble() ?? 0.0,
      customerType: json['customerType'] as String? ?? 'individual',
      companyId: json['companyId'] as String?,
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
      'email': email,
      'phone': phone,
      'address': address,
      'taxId': taxId,
      'creditLimit': creditLimit,
      'currentDebt': currentDebt,
      'customerType': customerType,
      'companyId': companyId,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}