class SubscriptionDTO {
  final String? id;
  final String? companyId;
  final String? plan; // 'basic', 'premium', 'enterprise'
  final double? monthlyPrice;
  final int? maxStores;
  final int? maxUsers;
  final int? maxProducts;
  final bool? hasAdvancedReports;
  final bool? hasInventoryManagement;
  final bool? hasMultiStore;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final String? status; // 'active', 'cancelled', 'suspended', 'expired'
  final String? paymentMethod;
  final String? stripeSubscriptionId; // Para integración con Stripe
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionDTO({
    this.id,
    required this.companyId,
    this.plan = 'basic',
    this.monthlyPrice = 29.99,
    this.maxStores = 1,
    this.maxUsers = 3,
    this.maxProducts = 100,
    this.hasAdvancedReports = false,
    this.hasInventoryManagement = true,
    this.hasMultiStore = false,
    required this.startDate,
    required this.endDate,
    this.nextBillingDate,
    this.status = 'active',
    this.paymentMethod,
    this.stripeSubscriptionId,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionDTO.fromJson(Map<String, dynamic> json) {
    return SubscriptionDTO(
      id: json['id'] as String?,
      companyId: json['companyId'] as String?,
      plan: json['plan'] as String? ?? 'basic',
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 29.99,
      maxStores: json['maxStores'] as int? ?? 1,
      maxUsers: json['maxUsers'] as int? ?? 3,
      maxProducts: json['maxProducts'] as int? ?? 100,
      hasAdvancedReports: json['hasAdvancedReports'] as bool? ?? false,
      hasInventoryManagement: json['hasInventoryManagement'] as bool? ?? true,
      hasMultiStore: json['hasMultiStore'] as bool? ?? false,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String)
          : null,
      nextBillingDate: json['nextBillingDate'] != null 
          ? DateTime.parse(json['nextBillingDate'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
      paymentMethod: json['paymentMethod'] as String?,
      stripeSubscriptionId: json['stripeSubscriptionId'] as String?,
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
      'companyId': companyId,
      'plan': plan,
      'monthlyPrice': monthlyPrice,
      'maxStores': maxStores,
      'maxUsers': maxUsers,
      'maxProducts': maxProducts,
      'hasAdvancedReports': hasAdvancedReports,
      'hasInventoryManagement': hasInventoryManagement,
      'hasMultiStore': hasMultiStore,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'stripeSubscriptionId': stripeSubscriptionId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Métodos útiles
  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired' || (endDate != null && endDate!.isBefore(DateTime.now()));
  bool get isExpiringSoon => endDate != null && endDate!.difference(DateTime.now()).inDays <= 7;
  int get daysUntilExpiry => endDate != null ? endDate!.difference(DateTime.now()).inDays : 0;
}