class StoreDTO {
  final String? id;
  final String? name;
  final String? address;
  final String? phone;
  final String? email;
  final String? companyId;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoreDTO({
    this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    required this.companyId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreDTO.fromJson(Map<String, dynamic> json) {
    return StoreDTO(
      id: json['id'] as String?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
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
      'address': address,
      'phone': phone,
      'email': email,
      'companyId': companyId,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
