class CategoryDTO {
  final String? id;
  final String? name;
  final String? description;
  final String? parentCategoryId; // Para categorías anidadas
  final String? color;
  final String? icon;
  final String? companyId;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryDTO({
    this.id,
    required this.name,
    this.description,
    this.parentCategoryId,
    this.color,
    this.icon,
    required this.companyId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryDTO(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      parentCategoryId: json['parentCategoryId'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
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
      'description': description,
      'parentCategoryId': parentCategoryId,
      'color': color,
      'icon': icon,
      'companyId': companyId,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}