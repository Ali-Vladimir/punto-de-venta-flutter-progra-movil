import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_dto.dart';
import '../models/sale_item_dto.dart';
import '../models/customer_dto.dart';
import 'base_firebase_service.dart';
import 'customer_service.dart';

class SaleService extends BaseFirebaseService<SaleDTO> {
  SaleService() : super('sales');

  @override
  SaleDTO fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleDTO.fromJson({
      'id': doc.id,
      ...data,
      'saleDate': BaseFirebaseService.convertTimestamp(data['saleDate']),
      'createdAt': BaseFirebaseService.convertTimestamp(data['createdAt']),
      'updatedAt': BaseFirebaseService.convertTimestamp(data['updatedAt']),
    });
  }

  @override
  Map<String, dynamic> toFirestore(SaleDTO sale) {
    final json = sale.toJson();
    json.remove('id');
    json.remove('createdAt');
    json.remove('updatedAt');
    
    // Convertir DateTime a Timestamp para Firebase
    if (json['saleDate'] != null) {
      json['saleDate'] = Timestamp.fromDate(DateTime.parse(json['saleDate']));
    }
    
    return json;
  }

  // Crear una venta completa con sus items - Versión simplificada
  Future<String> createSaleWithItems(
    String companyId, 
    SaleDTO sale, 
    List<SaleItemDTO> items
  ) async {
    try {
      print('💾 Iniciando creación de venta...');
      
      // Crear la venta principal
      final saleRef = getCompanyCollection(companyId).doc();
      final saleData = toFirestore(sale);
      saleData['createdAt'] = FieldValue.serverTimestamp();
      saleData['updatedAt'] = FieldValue.serverTimestamp();
      
      print('📍 Guardando venta en: companies/$companyId/$collectionName/${saleRef.id}');
      print('📄 Datos de venta: $saleData');
      
      await saleRef.set(saleData);
      print('✅ Venta principal creada: ${saleRef.id}');
      
      // Crear los items uno por uno para evitar problemas de batch
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final itemRef = saleRef.collection('items').doc();
        final itemJson = item.toJson();
        itemJson.remove('id');
        itemJson['saleId'] = saleRef.id;
        itemJson['createdAt'] = FieldValue.serverTimestamp();
        itemJson['updatedAt'] = FieldValue.serverTimestamp();
        
        await itemRef.set(itemJson);
        print('✅ Item ${i + 1}/${items.length} creado');
      }
      
      print('🎉 Venta completa creada: ${saleRef.id}');
      return saleRef.id;
    } catch (e) {
      print('❌ Error creando venta: $e');
      rethrow;
    }
  }

  // Obtener items de una venta
  Future<List<SaleItemDTO>> getSaleItems(String companyId, String saleId) async {
    final itemsSnapshot = await getCompanyCollection(companyId)
        .doc(saleId)
        .collection('items')
        .get();
    
    return itemsSnapshot.docs.map((doc) {
      final data = doc.data();
      return SaleItemDTO.fromJson({
        'id': doc.id,
        ...data,
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
        'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
      });
    }).toList();
  }

  // Obtener ventas por cliente
  Future<List<SaleDTO>> getSalesByCustomer(String companyId, String customerId) async {
    return await getWhere(companyId, 'customerId', customerId);
  }

  // Obtener ventas por tienda
  Future<List<SaleDTO>> getSalesByStore(String companyId, String storeId) async {
    return await getWhere(companyId, 'storeId', storeId);
  }

  // Obtener ventas por rango de fechas - Versión simplificada
  Future<List<SaleDTO>> getSalesByDateRange(
    String companyId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      // Obtener todas las ventas y filtrar localmente
      final snapshot = await getCompanyCollection(companyId).get();
      
      final results = <SaleDTO>[];
      
      for (final doc in snapshot.docs) {
        final sale = fromFirestore(doc);
        
        if (sale.saleDate != null) {
          final saleDate = sale.saleDate!;
          if (saleDate.isAfter(startDate.subtract(Duration(days: 1))) && 
              saleDate.isBefore(endDate.add(Duration(days: 1)))) {
            results.add(sale);
          }
        }
      }
      
      return results;
    } catch (e) {
      print('❌ Error obteniendo ventas por rango: $e');
      return [];
    }
  }

  // Obtener total de ventas del día - Versión ultra simplificada
  Future<double> getDailySalesTotal(String companyId, String storeId, DateTime date) async {
    try {
      // Consulta más simple posible - solo por storeId
      final snapshot = await getCompanyCollection(companyId)
          .where('storeId', isEqualTo: storeId)
          .get();
      
      final targetDate = DateTime(date.year, date.month, date.day);
      double total = 0.0;
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Verificar fecha localmente
        final saleDate = (data['saleDate'] as Timestamp?)?.toDate();
        if (saleDate != null) {
          final saleDateOnly = DateTime(saleDate.year, saleDate.month, saleDate.day);
          final status = data['status'] as String?;
          
          if (saleDateOnly == targetDate && status == 'completed') {
            total += (data['total'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }
      
      return total;
    } catch (e) {
      print('❌ Error obteniendo total de ventas: $e');
      return 0.0;
    }
  }

  // Generar número consecutivo de venta - Versión ultra simplificada
  Future<String> generateSaleNumber(String companyId, String storeId) async {
    final today = DateTime.now();
    final prefix = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    
    try {
      // Consulta más simple posible - solo por storeId
      final todaySales = await getCompanyCollection(companyId)
          .where('storeId', isEqualTo: storeId)
          .get();
      
      int maxConsecutive = 0;
      
      // Procesamos todas las ventas de esta tienda para encontrar el número más alto del día
      for (final doc in todaySales.docs) {
        final docData = doc.data() as Map<String, dynamic>?;
        final saleNumber = docData?['number'] as String?;
        
        // Solo procesar números que empiecen con el prefijo de hoy
        if (saleNumber != null && 
            saleNumber.startsWith(prefix) && 
            saleNumber.length == prefix.length + 4) { // Exactamente prefix + 4 dígitos
          final consecutivePart = saleNumber.substring(prefix.length);
          final parsed = int.tryParse(consecutivePart);
          if (parsed != null && parsed > maxConsecutive) {
            maxConsecutive = parsed;
          }
        }
      }
      
      final newConsecutive = maxConsecutive + 1;
      return '$prefix${newConsecutive.toString().padLeft(4, '0')}';
    } catch (e) {
      print('❌ Error generando número de venta: $e');
      // Fallback: usar timestamp como número único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$prefix${(timestamp % 10000).toString().padLeft(4, '0')}';
    }
  }

  // Eliminar una venta y actualizar deuda del cliente
  Future<void> deleteSaleWithItems(
    String companyId, 
    String saleId, 
    SaleDTO sale
  ) async {
    try {
      print('🗑️ Eliminando venta: $saleId');
      
      // Eliminar items de la venta
      final itemsSnapshot = await getCompanyCollection(companyId)
          .doc(saleId)
          .collection('items')
          .get();
      
      for (final itemDoc in itemsSnapshot.docs) {
        await itemDoc.reference.delete();
        print('✅ Item eliminado: ${itemDoc.id}');
      }
      
      // Eliminar la venta principal
      await getCompanyCollection(companyId).doc(saleId).delete();
      print('✅ Venta principal eliminada: $saleId');
      
      // Actualizar deuda del cliente si era venta a crédito
      if (sale.paymentMethod == 'credit' && sale.customerId != null) {
        await _updateCustomerDebtOnDelete(companyId, sale.customerId!, sale.total ?? 0.0);
      }
      
      print('🎉 Venta eliminada completamente: $saleId');
    } catch (e) {
      print('❌ Error eliminando venta: $e');
      rethrow;
    }
  }
  
  // Actualizar deuda del cliente al eliminar venta
  Future<void> _updateCustomerDebtOnDelete(String companyId, String customerId, double amount) async {
    try {
      final customerService = CustomerService();
      final customer = await customerService.getById(companyId, customerId);
      
      if (customer != null) {
        final updatedCustomer = CustomerDTO(
          id: customer.id,
          name: customer.name,
          email: customer.email,
          phone: customer.phone,
          address: customer.address,
          taxId: customer.taxId,
          creditLimit: customer.creditLimit,
          currentDebt: (customer.currentDebt ?? 0.0) - amount, // Restar la deuda
          customerType: customer.customerType,
          companyId: customer.companyId,
          isActive: customer.isActive,
          createdAt: customer.createdAt,
        );
        
        await customerService.update(companyId, customerId, updatedCustomer);
        print('✅ Deuda del cliente actualizada: -\$${amount.toStringAsFixed(2)}');
      }
    } catch (e) {
      print('❌ Error al actualizar deuda del cliente: $e');
      // No fallar la eliminación por esto
    }
  }

  // Actualizar una venta completa con sus items
  Future<void> updateSaleWithItems(
    String companyId,
    String saleId,
    SaleDTO sale,
    List<SaleItemDTO> items
  ) async {
    try {
      print('💾 Iniciando actualización de venta...');
      
      final batch = FirebaseFirestore.instance.batch();
      
      // Actualizar la venta principal
      final saleRef = getCompanyCollection(companyId).doc(saleId);
      final saleData = toFirestore(sale);
      saleData['updatedAt'] = FieldValue.serverTimestamp();
      
      batch.update(saleRef, saleData);
      
      // Eliminar items existentes
      final existingItemsSnapshot = await saleRef
          .collection('items')
          .get();
      
      for (final doc in existingItemsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Agregar los nuevos items
      for (final item in items) {
        final itemRef = saleRef.collection('items').doc();
        final itemData = item.toJson();
        itemData.remove('id');
        itemData['saleId'] = saleId;
        itemData['createdAt'] = FieldValue.serverTimestamp();
        
        batch.set(itemRef, itemData);
      }
      
      // Ejecutar todas las operaciones
      await batch.commit();
      
      print('✅ Venta actualizada exitosamente: $saleId');
      
    } catch (e) {
      print('❌ Error actualizando venta: $e');
      throw Exception('Error al actualizar venta: $e');
    }
  }
}