class CompanyDTO {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? subscriptionPlan;
  final DateTime? subscriptionExpiresAt;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompanyDTO({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.subscriptionPlan = 'basic',
    this.subscriptionExpiresAt,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyDTO.fromJson(Map<String, dynamic> json) {
    return CompanyDTO(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      subscriptionPlan: json['subscriptionPlan'] as String? ?? 'basic',
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null 
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
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
      'subscriptionPlan': subscriptionPlan,
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
