import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/customer_dto.dart';

class WhatsAppService {
  static final Dio _dio = Dio();
  
  static Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Validar configuración
      if (!AppConfig.isWhatsappConfigured) {
        print('❌ WhatsApp no configurado correctamente');
        AppConfig.validateConfiguration();
        return false;
      }
      
      print('📱 Enviando WhatsApp a: $phoneNumber');
      
      final response = await _dio.post(
        AppConfig.whatsappApiUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AppConfig.whatsappApiToken}',
          },
          sendTimeout: Duration(milliseconds: AppConfig.apiTimeout),
          receiveTimeout: Duration(milliseconds: AppConfig.apiTimeout),
        ),
        data: {
          'chatId': _formatPhoneNumber(phoneNumber),
          'text': message,
          'sessionName': AppConfig.whatsappSessionId,
          if (AppConfig.whatsappSessionId.isNotEmpty) 
            'session': AppConfig.whatsappSessionId,
        },
      );
      
      if (response.statusCode == 200) {
        print('✅ WhatsApp enviado exitosamente');
        if (AppConfig.isDebugMode) {
          print('📋 Respuesta: ${response.data}');
        }
        return true;
      } else {
        print('❌ Error enviando WhatsApp: ${response.statusCode}');
        if (AppConfig.isDebugMode) {
          print('📋 Respuesta completa: ${response.data}');
        }
        return false;
      }
    } on DioException catch (e) {
      print('❌ Error de Dio en WhatsApp: ${e.message}');
      if (AppConfig.isDebugMode) {
        print('🔍 Detalles del error: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('❌ Excepción en WhatsApp: $e');
      return false;
    }
  }
  
  static String _formatPhoneNumber(String phone) {
    // Remover espacios y caracteres especiales
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Agregar código de país si no lo tiene (México +52)
    if (!cleaned.startsWith('52') && cleaned.length == 10) {
      cleaned = '521$cleaned';
    }
    
    return cleaned;
  }
  
  // Plantillas de mensajes
  static String buildSaleReceiptMessage({
    required String saleNumber,
    required CustomerDTO customer,
    required double total,
    required String paymentMethod,
    required List<SaleItemInfo> items,
  }) {
    final customerName = customer.name ?? 'Cliente';
    final currentDebt = customer.currentDebt ?? 0.0;
    final creditLimit = customer.creditLimit ?? 0.0;
    final now = DateTime.now();
    
    String paymentMethodText;
    switch (paymentMethod) {
      case 'cash':
        paymentMethodText = 'Efectivo';
        break;
      case 'card':
        paymentMethodText = 'Tarjeta';
        break;
      case 'credit':
        paymentMethodText = 'Crédito';
        break;
      default:
        paymentMethodText = paymentMethod;
    }
    
    return '''
🛒 *Resumen de Venta*

Hola $customerName,

✅ Tu compra ha sido procesada exitosamente

📋 *Detalles de la venta:*
• Número: #$saleNumber
• Fecha: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}
• *Total: \$${total.toStringAsFixed(2)}*
• Método de pago: $paymentMethodText

📦 *Productos comprados:*
${items.map((item) => '• ${item.name} (${item.quantity}) - \$${item.subtotal.toStringAsFixed(2)}').join('\n')}

💳 *Estado de cuenta:*
• Deuda actual: \$${currentDebt.toStringAsFixed(2)}
• Límite de crédito: \$${creditLimit.toStringAsFixed(2)}
• Crédito disponible: \$${(creditLimit - currentDebt).toStringAsFixed(2)}

¡Gracias por tu compra! 🙏
''';
  }
  
  static String buildSaleDeletedMessage({
    required CustomerDTO customer,
    required String saleNumber,
    required double deletedAmount,
  }) {
    final customerName = customer.name ?? 'Cliente';
    final currentDebt = customer.currentDebt ?? 0.0;
    final creditLimit = customer.creditLimit ?? 0.0;
    final now = DateTime.now();
    
    return '''
🗑️ *Venta Cancelada*

Hola $customerName,

❌ La venta ha sido cancelada

📋 *Detalles de la cancelación:*
• Número de venta: #$saleNumber
• Fecha de cancelación: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}
• Monto cancelado: \$${deletedAmount.toStringAsFixed(2)}

💳 *Estado de cuenta actualizado:*
• Deuda actual: \$${currentDebt.toStringAsFixed(2)}
• Límite de crédito: \$${creditLimit.toStringAsFixed(2)}
• Crédito disponible: \$${(creditLimit - currentDebt).toStringAsFixed(2)}

Si tienes alguna pregunta sobre esta cancelación, no dudes en contactarnos.

Gracias por tu comprensión 🙏
''';
  }
  
  static String buildSaleEditedMessage({
    required CustomerDTO customer,
    required String saleNumber,
    required double newTotal,
    required double previousTotal,
    required String paymentMethod,
    required List<SaleItemInfo> items,
  }) {
    final customerName = customer.name ?? 'Cliente';
    final currentDebt = customer.currentDebt ?? 0.0;
    final creditLimit = customer.creditLimit ?? 0.0;
    final now = DateTime.now();
    final difference = newTotal - previousTotal;
    
    String paymentMethodText;
    switch (paymentMethod) {
      case 'cash':
        paymentMethodText = 'Efectivo';
        break;
      case 'card':
        paymentMethodText = 'Tarjeta';
        break;
      case 'credit':
        paymentMethodText = 'Crédito';
        break;
      default:
        paymentMethodText = paymentMethod;
    }
    
    return '''
✏️ *Venta Modificada*

Hola $customerName,

✅ Tu venta ha sido modificada

📋 *Detalles de la modificación:*
• Número de venta: #$saleNumber
• Fecha de modificación: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}
• Total anterior: \$${previousTotal.toStringAsFixed(2)}
• *Nuevo total: \$${newTotal.toStringAsFixed(2)}*
• Diferencia: ${difference >= 0 ? '+' : ''}\$${difference.toStringAsFixed(2)}
• Método de pago: $paymentMethodText

📦 *Productos actualizados:*
${items.map((item) => '• ${item.name} (${item.quantity}) - \$${item.subtotal.toStringAsFixed(2)}').join('\n')}

💳 *Estado de cuenta actualizado:*
• Deuda actual: \$${currentDebt.toStringAsFixed(2)}
• Límite de crédito: \$${creditLimit.toStringAsFixed(2)}
• Crédito disponible: \$${(creditLimit - currentDebt).toStringAsFixed(2)}

¡Gracias por tu compra! 🙏
''';
  }
  
  static String buildCreditLimitExceededMessage({
    required CustomerDTO customer,
    required double attemptedTotal,
  }) {
    final customerName = customer.name ?? 'Cliente';
    final currentDebt = customer.currentDebt ?? 0.0;
    final creditLimit = customer.creditLimit ?? 0.0;
    
    return '''
🚫 *Límite de Crédito Excedido*

Hola $customerName,

No fue posible procesar tu compra por el siguiente motivo:

💳 *Estado de tu cuenta:*
• Deuda actual: \$${currentDebt.toStringAsFixed(2)}
• Límite de crédito: \$${creditLimit.toStringAsFixed(2)}
• Total de la compra: \$${attemptedTotal.toStringAsFixed(2)}
• Excedente: \$${(currentDebt + attemptedTotal - creditLimit).toStringAsFixed(2)}

📞 Para realizar esta compra puedes:
• Realizar un abono a tu cuenta
• Pagar en efectivo o tarjeta
• Contactarnos para revisar tu límite

¡Gracias por tu comprensión! 🙏
''';
  }
  
  static String buildPaymentReminderMessage({
    required CustomerDTO customer,
  }) {
    final customerName = customer.name ?? 'Cliente';
    final currentDebt = customer.currentDebt ?? 0.0;
    final creditLimit = customer.creditLimit ?? 0.0;
    
    return '''
📢 *Recordatorio de Pago*

Hola $customerName,

Te recordamos que tienes un saldo pendiente en tu cuenta:

💳 *Estado de cuenta:*
• Deuda actual: \$${currentDebt.toStringAsFixed(2)}
• Límite de crédito: \$${creditLimit.toStringAsFixed(2)}
• Crédito disponible: \$${(creditLimit - currentDebt).toStringAsFixed(2)}

💰 Puedes realizar tu pago por:
• Transferencia bancaria
• Efectivo en tienda
• Depósito en cuenta

¡Gracias por mantenerte al día! 🙏
''';
  }
}

class SaleItemInfo {
  final String name;
  final double quantity;
  final double subtotal;

  SaleItemInfo({
    required this.name,
    required this.quantity,
    required this.subtotal,
  });
}