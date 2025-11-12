class RoleDTO {
  final String? id;
  final String? name;
  final String? description;
  final List<String>? permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoleDTO({
    this.id,
    required this.name,
    this.description,
    this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleDTO.fromJson(Map<String, dynamic> json) {
    return RoleDTO(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      permissions: json['permissions'] != null 
          ? List<String>.from(json['permissions'] as List)
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
      'name': name,
      'description': description,
      'permissions': permissions,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
