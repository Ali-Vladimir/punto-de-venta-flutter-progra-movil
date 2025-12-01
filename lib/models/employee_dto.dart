import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeDTO {
  final String? employeeId;
  final String? userId; // Referencia a UserInfo si está en Firebase Auth
  final String displayName;
  final String email;
  final String? phone;
  final String position; // Cargo: Cajero, Vendedor, Gerente, etc.
  final String? department; // Departamento: Ventas, Almacén, etc.
  final double salary;
  final String? photoURL;
  final String? storeId; // Tienda asignada
  final String companyId;
  final bool isActive;
  final DateTime hireDate; // Fecha de contratación
  final DateTime? terminationDate; // Fecha de terminación (si aplica)
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final List<String>? permissions; // Permisos específicos
  final Map<String, dynamic>? schedule; // Horario de trabajo
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EmployeeDTO({
    this.employeeId,
    this.userId,
    required this.displayName,
    required this.email,
    this.phone,
    required this.position,
    this.department,
    required this.salary,
    this.photoURL,
    this.storeId,
    required this.companyId,
    this.isActive = true,
    required this.hireDate,
    this.terminationDate,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    this.permissions,
    this.schedule,
    this.createdAt,
    this.updatedAt,
  });

  // Helper para convertir Timestamp o String a DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) throw ArgumentError('DateTime value cannot be null');
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    throw ArgumentError('Cannot parse DateTime from ${value.runtimeType}');
  }

  // Helper para convertir Timestamp o String a DateTime nullable
  static DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    return null;
  }

  factory EmployeeDTO.fromJson(Map<String, dynamic> json) {
    return EmployeeDTO(
      employeeId: json['employeeId'] as String?,
      userId: json['userId'] as String?,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      position: json['position'] as String,
      department: json['department'] as String?,
      salary: (json['salary'] as num).toDouble(),
      photoURL: json['photoURL'] as String?,
      storeId: json['storeId'] as String?,
      companyId: json['companyId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      hireDate: _parseDateTime(json['hireDate']),
      terminationDate: _parseDateTimeNullable(json['terminationDate']),
      address: json['address'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyPhone: json['emergencyPhone'] as String?,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'] as List)
          : null,
      schedule: json['schedule'] as Map<String, dynamic>?,
      createdAt: _parseDateTimeNullable(json['createdAt']),
      updatedAt: _parseDateTimeNullable(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
      'salary': salary,
      'photoURL': photoURL,
      'storeId': storeId,
      'companyId': companyId,
      'isActive': isActive,
      'hireDate': hireDate.toIso8601String(),
      'terminationDate': terminationDate?.toIso8601String(),
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'permissions': permissions,
      'schedule': schedule,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  EmployeeDTO copyWith({
    String? employeeId,
    String? userId,
    String? displayName,
    String? email,
    String? phone,
    String? position,
    String? department,
    double? salary,
    String? photoURL,
    String? storeId,
    String? companyId,
    bool? isActive,
    DateTime? hireDate,
    DateTime? terminationDate,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    List<String>? permissions,
    Map<String, dynamic>? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeDTO(
      employeeId: employeeId ?? this.employeeId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      department: department ?? this.department,
      salary: salary ?? this.salary,
      photoURL: photoURL ?? this.photoURL,
      storeId: storeId ?? this.storeId,
      companyId: companyId ?? this.companyId,
      isActive: isActive ?? this.isActive,
      hireDate: hireDate ?? this.hireDate,
      terminationDate: terminationDate ?? this.terminationDate,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      permissions: permissions ?? this.permissions,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
