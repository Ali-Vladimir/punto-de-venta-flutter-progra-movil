# Configuración de WhatsApp API para Punto de Venta

## 🔐 Configuración Segura con Variables de Entorno

El sistema POS ahora maneja tokens y endpoints de forma segura usando **variables de entorno** que no se suben al repositorio.

## 🚀 **¿Por qué Dio en lugar de HTTP?**

**Dio es superior por:**
- ✅ **Interceptors**: Para logging y manejo de errores automático
- ✅ **Timeouts configurables**: Mejor control de conexiones
- ✅ **Request/Response transformation**: Más flexible
- ✅ **Better error handling**: DioException con más detalles
- ✅ **Built-in JSON serialization**: Más eficiente
- ✅ **Cancelation tokens**: Para cancelar requests
- ✅ **Global configuration**: Headers y configuración reutilizable

## 📋 Setup Paso a Paso

### 1. **Configurar Variables de Entorno**

Copia el archivo de ejemplo y configúralo con tus datos:
```bash
cp .env.example .env
```

Edita `.env` con tus credenciales reales:
```env
# WhatsApp API Configuration
WHATSAPP_API_URL=https://tu-api-whatsapp.com/api/v1/messages
WHATSAPP_API_TOKEN=tu_token_super_secreto_aqui
WHATSAPP_SESSION_ID=tu_session_id_aqui

# Configuración
ENVIRONMENT=development
DEBUG_MODE=true
API_TIMEOUT=30000
```

### 2. **Instalar Dependencias**
```bash
flutter pub get
```

### 3. **¡Listo!** El sistema cargará automáticamente tu configuración.

## 🔧 **Configuración por Proveedor**

### WhatsApp Business API (Meta)
```env
WHATSAPP_API_URL=https://graph.facebook.com/v18.0/{phone-number-id}/messages
WHATSAPP_API_TOKEN=tu_facebook_access_token
```

### Twilio WhatsApp API
```env
WHATSAPP_API_URL=https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages.json
WHATSAPP_API_TOKEN=tu_twilio_auth_token
```

### ChatAPI, Wassenger, etc.
```env
WHATSAPP_API_URL=https://api.chat-api.com/instance{instance_id}/sendMessage
WHATSAPP_API_TOKEN=tu_api_token
WHATSAPP_SESSION_ID=tu_session_id
```

## 🛡️ **Seguridad Implementada**

### ✅ Variables de Entorno
- **Archivo `.env`** excluido del repo (`.gitignore`)
- **No hay tokens en el código fuente**
- **Configuración centralizada** en `AppConfig`

### ✅ Validación Automática
- Verifica que todas las variables estén configuradas
- Muestra advertencias si faltan configuraciones
- Modo debug para troubleshooting

### ✅ Manejo de Errores Robusto
```dart
// Timeout configurables
sendTimeout: Duration(milliseconds: AppConfig.apiTimeout)

// Manejo específico de errores de Dio
on DioException catch (e) {
  // Manejo específico según el tipo de error
}
```

## 📱 **Estructura de Archivos**

```
lib/
├── config/
│   └── app_config.dart          # Configuración centralizada
├── services/
│   └── whatsapp_service.dart    # Servicio WhatsApp con Dio
└── screens/
    └── admin/
        └── new_sale_screen.dart # Pantalla POS integrada

.env                            # TUS VARIABLES (no se sube al repo)
.env.example                    # Plantilla para otros desarrolladores
```

## 🔍 **Debugging y Testing**

### Logs Detallados (Solo en DEBUG_MODE=true)
```
🔧 Configuración de la app:
   Environment: development
   Debug Mode: true
   WhatsApp URL: ✅ Configurado
   WhatsApp Token: ✅ Configurado
   API Timeout: 30000ms
```

### Validación Automática
```
⚠️ Configuración faltante en .env: WHATSAPP_API_TOKEN
📄 Consulta .env.example para ver las variables requeridas
```

## 🚀 **Funcionalidades Completas**

### ✅ Validación de Límite de Crédito
### ✅ Actualización Automática de Deuda  
### ✅ Guardado en Firestore con ID único
### ✅ WhatsApp con Variables Seguras
### ✅ Manejo de Errores Robusto

## 📦 **Dependencias Nuevas**

```yaml
dependencies:
  dio: ^5.4.0                    # HTTP client superior
  flutter_dotenv: ^5.1.0        # Variables de entorno
```

## 🔒 **IMPORTANTE: Seguridad**

### ❌ **NUNCA hagas esto:**
```dart
// ❌ MAL - Token expuesto en código
static const String token = 'abc123...';
```

### ✅ **SIEMPRE haz esto:**
```dart
// ✅ BIEN - Variable de entorno
static String get token => AppConfig.whatsappApiToken;
```

### 📝 **Para colaboradores:**
1. Copia `.env.example` a `.env`
2. Pide las credenciales al admin del proyecto
3. Configura tu archivo `.env` local
4. **Nunca** commites el archivo `.env`

## 🛠 **Testing sin WhatsApp Real**

```dart
// En .env para testing
DEBUG_MODE=true
WHATSAPP_API_URL=https://httpbin.org/post  # Mock endpoint
```

## 🆘 **Troubleshooting**

### Error: "WhatsApp no configurado correctamente"
1. Verifica que `.env` existe en la raíz del proyecto
2. Confirma que las variables están definidas
3. Revisa que no hay espacios extra en los valores

### Error: "DioException"
1. Verifica tu endpoint en `.env`
2. Confirma que tu token es válido
3. Revisa la conectividad a internet

### Variables no se cargan
1. Ejecuta `flutter pub get`
2. Reinicia la app completamente
3. Verifica que `.env` está en `pubspec.yaml` assets

¡Ahora tu app maneja tokens de forma profesional y segura! 🔐✨