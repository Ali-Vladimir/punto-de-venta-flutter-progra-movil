import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_dto.dart';
import 'base_firebase_service.dart';

class EmployeeService extends BaseFirebaseService<EmployeeDTO> {
  EmployeeService() : super('employees');

  @override
  EmployeeDTO fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['employeeId'] = doc.id;
    return EmployeeDTO.fromJson(data);
  }

  @override
  Map<String, dynamic> toFirestore(EmployeeDTO employee) {
    final data = employee.toJson();
    data.remove('employeeId');
    data.remove('createdAt');
    data.remove('updatedAt');
    return data;
  }

  // Obtener empleados por compañía
  Future<List<EmployeeDTO>> getByCompanyId(String companyId) async {
    try {
      return await getAll(companyId);
    } catch (e) {
      throw Exception('Error al obtener empleados: $e');
    }
  }

  // Obtener empleados activos
  Future<List<EmployeeDTO>> getActiveEmployees(String companyId) async {
    try {
      return await getWhere(companyId, 'isActive', true);
    } catch (e) {
      throw Exception('Error al obtener empleados activos: $e');
    }
  }

  // Obtener empleados por tienda
  Future<List<EmployeeDTO>> getByStoreId(
      String companyId, String storeId) async {
    try {
      final querySnapshot = await getCompanyCollection(companyId)
          .where('storeId', isEqualTo: storeId)
          .where('isActive', isEqualTo: true)
          .orderBy('displayName')
          .get();

      return querySnapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error al obtener empleados de la tienda: $e');
    }
  }

  // Obtener empleados por cargo/posición
  Future<List<EmployeeDTO>> getByPosition(
      String companyId, String position) async {
    try {
      return await getWhere(companyId, 'position', position);
    } catch (e) {
      throw Exception('Error al obtener empleados por posición: $e');
    }
  }

  // Obtener empleados por departamento
  Future<List<EmployeeDTO>> getByDepartment(
      String companyId, String department) async {
    try {
      return await getWhere(companyId, 'department', department);
    } catch (e) {
      throw Exception('Error al obtener empleados por departamento: $e');
    }
  }

  // Buscar empleados por nombre o email
  Future<List<EmployeeDTO>> searchEmployees(
      String companyId, String searchTerm) async {
    try {
      final employees = await getAll(companyId);
      final searchLower = searchTerm.toLowerCase();
      
      return employees.where((employee) {
        return employee.displayName.toLowerCase().contains(searchLower) ||
            employee.email.toLowerCase().contains(searchLower) ||
            (employee.phone?.contains(searchTerm) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Error al buscar empleados: $e');
    }
  }

  // Desactivar empleado (soft delete)
  Future<void> deactivateEmployee(String companyId, String employeeId) async {
    try {
      await getCompanyCollection(companyId).doc(employeeId).update({
        'isActive': false,
        'terminationDate': DateTime.now().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al desactivar empleado: $e');
    }
  }

  // Reactivar empleado
  Future<void> reactivateEmployee(String companyId, String employeeId) async {
    try {
      await getCompanyCollection(companyId).doc(employeeId).update({
        'isActive': true,
        'terminationDate': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al reactivar empleado: $e');
    }
  }

  // Obtener estadísticas de empleados
  Future<Map<String, dynamic>> getEmployeeStats(String companyId) async {
    try {
      final allEmployees = await getAll(companyId);
      final activeEmployees = allEmployees.where((e) => e.isActive).toList();

      final Map<String, int> positionCounts = {};
      for (var employee in activeEmployees) {
        positionCounts[employee.position] =
            (positionCounts[employee.position] ?? 0) + 1;
      }

      final Map<String, int> departmentCounts = {};
      for (var employee in activeEmployees) {
        if (employee.department != null) {
          departmentCounts[employee.department!] =
              (departmentCounts[employee.department!] ?? 0) + 1;
        }
      }

      final totalPayroll =
          activeEmployees.fold<double>(0, (sum, e) => sum + e.salary);

      return {
        'totalEmployees': allEmployees.length,
        'activeEmployees': activeEmployees.length,
        'inactiveEmployees': allEmployees.length - activeEmployees.length,
        'positionCounts': positionCounts,
        'departmentCounts': departmentCounts,
        'totalPayroll': totalPayroll,
        'averageSalary':
            activeEmployees.isEmpty ? 0 : totalPayroll / activeEmployees.length,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Stream para escuchar cambios en empleados
  Stream<List<EmployeeDTO>> streamByCompanyId(String companyId) {
    return getAllMappedStream(companyId);
  }
}

