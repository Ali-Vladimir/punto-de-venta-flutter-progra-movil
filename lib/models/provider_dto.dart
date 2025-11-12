class ProviderDTO {
  final String? id;
  final String? name;
  final String? email;
  final String? contact;
  final String? phone;
  final String? bankAccount;
  final String? address;
  final String? companyId;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProviderDTO({
    this.id,
    required this.name,
    this.email,
    this.contact,
    this.phone,
    this.bankAccount,
    this.address,
    required this.companyId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProviderDTO.fromJson(Map<String, dynamic> json) {
    return ProviderDTO(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      contact: json['contact'] as String?,
      phone: json['phone'] as String?,
      bankAccount: json['bankAccount'] as String?,
      address: json['address'] as String?,
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
      'contact': contact,
      'phone': phone,
      'bankAccount': bankAccount,
      'address': address,
      'companyId': companyId,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
