import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // WhatsApp Configuration
  static String get whatsappApiUrl => dotenv.env['WHATSAPP_API_URL'] ?? '';
  static String get whatsappApiToken => dotenv.env['WHATSAPP_API_TOKEN'] ?? '';
  static String get whatsappSessionId => dotenv.env['WHATSAPP_SESSION_ID'] ?? '';
  
  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
  
  // Environment
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'production';
  static bool get isDebugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  
  // Validation methods
  static bool get isWhatsappConfigured => 
      whatsappApiUrl.isNotEmpty && whatsappApiToken.isNotEmpty;
  
  static void validateConfiguration() {
    final missing = <String>[];
    
    if (whatsappApiUrl.isEmpty) missing.add('WHATSAPP_API_URL');
    if (whatsappApiToken.isEmpty) missing.add('WHATSAPP_API_TOKEN');
    
    if (missing.isNotEmpty) {
      print('⚠️ Configuración faltante en .env: ${missing.join(', ')}');
      print('📄 Consulta .env.example para ver las variables requeridas');
    }
  }
  
  // Debug helper
  static void printConfiguration() {
    if (isDebugMode) {
      print('🔧 Configuración de la app:');
      print('   Environment: $environment');
      print('   Debug Mode: $isDebugMode');
      print('   WhatsApp URL: ${whatsappApiUrl.isNotEmpty ? "✅ Configurado" : "❌ Faltante"}');
      print('   WhatsApp Token: ${whatsappApiToken.isNotEmpty ? "✅ Configurado" : "❌ Faltante"}');
      print('   API Timeout: ${apiTimeout}ms');
    }
  }
}