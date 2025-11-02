# Firebase Auth - Integración Completa

## 📋 Tabla de Contenidos

- [Resumen de Implementación](#resumen-de-implementación)
- [Arquitectura](#arquitectura)
- [Archivos Creados](#archivos-creados)
- [Configuración de Firebase](#configuración-de-firebase)
- [Características Implementadas](#características-implementadas)
- [Uso en la Aplicación](#uso-en-la-aplicación)
- [Solución de Problemas](#solución-de-problemas)

---

## Resumen de Implementación

✅ **Sistema completo de autenticación con Firebase Auth:**

- ✅ Login con email y contraseña
- ✅ Registro de nuevos usuarios con email y contraseña
- ✅ Google Sign-In
- ✅ Recuperación de contraseña
- ✅ Manejo de errores en español
- ✅ Arquitectura MVC con Riverpod

### Dependencias Añadidas

```yaml
firebase_auth: ^5.0.0
google_sign_in: ^6.2.1
```

---

## Arquitectura

Siguiendo el patrón MVC con Riverpod que ya tienes en el proyecto:

```
┌─────────────────────────────────────────────────────────────┐
│                         DOMAIN LAYER                        │
│  (Contratos e interfaces - Sin dependencias de Firebase)   │
├─────────────────────────────────────────────────────────────┤
│  • auth_repository.dart                                     │
│    - Interface AuthRepository                               │
│    - Define métodos abstractos para autenticación          │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ implements
                            │
┌─────────────────────────────────────────────────────────────┐
│                         DATA LAYER                          │
│        (Implementaciones concretas con Firebase)            │
├─────────────────────────────────────────────────────────────┤
│  DATASOURCE:                                                │
│  • firebase_auth_datasource.dart                           │
│    - Lógica directa con FirebaseAuth                       │
│    - Manejo de GoogleSignIn                                │
│    - Traducción de errores a español                       │
│                                                             │
│  REPOSITORY:                                                │
│  • firebase_auth_repository.dart                           │
│    - Implementa AuthRepository                             │
│    - Delega llamadas al datasource                         │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ uses
                            │
┌─────────────────────────────────────────────────────────────┐
│                       PROVIDERS LAYER                       │
│              (Riverpod - Estado global)                     │
├─────────────────────────────────────────────────────────────┤
│  • auth_providers.dart                                      │
│    - authRepositoryProvider                                 │
│    - authStateChangesProvider (Stream<User?>)              │
│    - currentUserProvider                                    │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ consume
                            │
┌─────────────────────────────────────────────────────────────┐
│                         PAGES LAYER                         │
│                    (UI - ConsumerWidget)                    │
├─────────────────────────────────────────────────────────────┤
│  • login_page.dart                                          │
│    - ref.read(authRepositoryProvider)                       │
│    - Llama a signInWithEmailAndPassword()                  │
│    - Llama a registerWithEmailAndPassword()                │
│    - Llama a signInWithGoogle()                            │
│    - Manejo de errores con SnackBar                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Archivos Creados

### 1. Domain Layer

**`lib/domain/repositories/auth_repository.dart`**

```dart
// Contrato abstracto - Sin dependencias de Firebase
abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
```

### 2. Data Layer

**`lib/data/datasources/firebase_auth_datasource.dart`**

- Maneja todas las llamadas a `FirebaseAuth.instance`
- Integra `GoogleSignIn` para autenticación con Google
- Método `_handleAuthException()` traduce errores de Firebase a español

**Errores manejados:**

- `user-not-found` → "No existe una cuenta con este correo electrónico"
- `wrong-password` → "Contraseña incorrecta"
- `email-already-in-use` → "Ya existe una cuenta con este correo electrónico"
- `weak-password` → "La contraseña debe tener al menos 6 caracteres"
- `invalid-email` → "Correo electrónico inválido"
- Y más...

**`lib/data/repositories/firebase_auth_repository.dart`**

- Implementa `AuthRepository`
- Delega todas las operaciones al datasource
- Actúa como puente entre dominio y datos

### 3. Providers Layer

**`lib/providers/auth_providers.dart`**

```dart
/// Provider del repositorio (singleton)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Stream que emite User cuando cambia el estado de auth
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Usuario actual (snapshot)
final currentUserProvider = Provider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});
```

### 4. Pages Layer

**`lib/pages/login_page.dart`** (Modificado)

**Cambios principales:**

1. `StatefulWidget` → `ConsumerStatefulWidget`
2. `State<LoginPage>` → `ConsumerState<LoginPage>`
3. Añadido campo `_isLogin` para toggle entre login/registro
4. Métodos nuevos:
   - `_submit()` → Login o registro según `_isLogin`
   - `_signInWithGoogle()` → Autenticación con Google
   - `_forgotPassword()` → Envía email de recuperación

**UI Nueva:**

- ✅ Botón "START" / "REGISTER" (cambia según modo)
- ✅ Botón blanco con logo de Google para "Continuar con Google"
- ✅ Toggle "¿No tienes cuenta? Regístrate" / "¿Ya tienes cuenta? Inicia sesión"
- ✅ Link "¿Olvidaste tu contraseña?" (solo en modo login)
- ✅ Validación: contraseña ≥ 6 caracteres en modo registro
- ✅ SnackBars con errores en español

---

## Configuración de Firebase

### ⚠️ CRÍTICO: Habilitar Métodos de Autenticación

**ANTES de usar la app**, debes habilitar los métodos de autenticación en Firebase Console:

#### Paso 0: Habilitar Email/Password (OBLIGATORIO)

**Este paso es NECESARIO para que funcione el registro y login con email.**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto **gamerank-18bd3**
3. En el menú izquierdo, click en **Authentication**
4. Click en la pestaña **"Sign-in method"**
5. Busca **"Email/Password"** en la lista
6. Click en **"Email/Password"**
7. Activa el toggle **"Enable"** (Habilitar)
8. Click en **"Save"** (Guardar)

**Sin este paso, verás el error:**

```
E/RecaptchaCallWrapper: Initial task failed for action RecaptchaAction(action=signUpPassword)
with exception - An internal error has occurred. [ CONFIGURATION_NOT_FOUND ]
```

### ⚠️ IMPORTANTE: Configuración Pendiente

Para que la autenticación funcione, **DEBES completar estos pasos**:

#### ✅ Paso 0: Habilitar Email/Password (OBLIGATORIO)

**Hazlo PRIMERO antes de intentar registrar usuarios:**

1. [Firebase Console](https://console.firebase.google.com/) → Proyecto **gamerank-18bd3**
2. **Authentication** → **Sign-in method**
3. Click en **"Email/Password"**
4. Activar toggle **"Enable"**
5. **Save**

**Si no haces esto, verás el error: `CONFIGURATION_NOT_FOUND`**

#### 🔹 Configuración Adicional para Google Sign-In (Opcional)

Solo necesario si quieres usar **"Continuar con Google"**:

#### Paso 1: Obtener tu SHA-1

El SHA-1 es una huella digital de tu app necesaria para Google Sign-In en Android.

```bash
cd /home/arbey/Documentos/proyectos/ut/game_rank/android

# Obtener SHA-1 de debug (para desarrollo)
./gradlew signingReport
```

Busca en la salida algo como:

```
Variant: debug
Config: debug
Store: ~/.android/debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX...
SHA1: A1:B2:C3:D4:E5:F6:...  <-- ¡COPIA ESTE!
SHA-256: ...
```

**Copia el SHA-1 que aparece en la sección "debug".**

#### Paso 2: Agregar SHA-1 a Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto **gamerank-18bd3**
3. Ve a **Configuración del proyecto** (ícono de engranaje)
4. Scroll down hasta **Tus apps**
5. Encuentra tu app Android: `com.example.game_rank`
6. Click en **"Agregar huella digital"**
7. Pega el SHA-1 que copiaste
8. Click **"Guardar"**

#### Paso 3: Habilitar Google Sign-In (Opcional)

**Solo si quieres usar "Continuar con Google":**

1. En Firebase Console, ve a **Authentication** (menú izquierdo)
2. Ve a la pestaña **"Sign-in method"**
3. Click en **"Google"**
4. Click en el toggle para **"Habilitar"**
5. Ingresa un **email de asistencia** (puede ser el tuyo)
6. Click **"Guardar"**

#### Paso 4: Descargar nuevo google-services.json

Después de agregar el SHA-1, Firebase genera un nuevo archivo con OAuth configurado.

1. En **Configuración del proyecto** → **Tus apps**
2. Click en tu app Android
3. Click en **"google-services.json"** para descargarlo
4. **Reemplaza** el archivo en tu proyecto:
   ```bash
   # Desde donde descargaste el archivo
   cp ~/Downloads/google-services.json \
      /home/arbey/Documentos/proyectos/ut/game_rank/android/app/
   ```

El nuevo archivo debe tener `oauth_client` con contenido:

```json
"oauth_client": [
  {
    "client_id": "948780151517-xxxxxxxxx.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

#### Paso 5: Reconstruir la app

```bash
cd /home/arbey/Documentos/proyectos/ut/game_rank

# Limpiar build anterior
flutter clean

# Reinstalar dependencias
flutter pub get

# Rebuild
flutter run
```

---

## Características Implementadas

### 1. Login con Email/Contraseña

```dart
// Usuario hace click en "START"
await authRepository.signInWithEmailAndPassword(
  email: 'usuario@ejemplo.com',
  password: 'miPassword123',
);
```

**Validaciones:**

- Email no vacío
- Contraseña no vacía
- Errores mostrados en SnackBar

### 2. Registro de Nuevos Usuarios

```dart
// Usuario cambia a modo "Registro" y hace click en "REGISTER"
await authRepository.registerWithEmailAndPassword(
  email: 'nuevo@ejemplo.com',
  password: 'password123',
);
```

**Validaciones adicionales:**

- Contraseña ≥ 6 caracteres (requerido por Firebase)
- Error si email ya está en uso

### 3. Google Sign-In

```dart
// Usuario hace click en "Continuar con Google"
await authRepository.signInWithGoogle();
```

**Flujo:**

1. Se abre selector de cuenta de Google
2. Usuario selecciona cuenta
3. Firebase crea usuario automáticamente si no existe
4. Usuario autenticado con éxito

**Cancelación:** Si el usuario cancela, muestra error "Inicio de sesión con Google cancelado"

### 4. Recuperación de Contraseña

```dart
// Usuario hace click en "¿Olvidaste tu contraseña?"
await authRepository.sendPasswordResetEmail('usuario@ejemplo.com');
```

**Requisito:** El email debe estar en el campo de email.

**Resultado:** Firebase envía email con link de recuperación.

### 5. Cerrar Sesión

```dart
final authRepository = ref.read(authRepositoryProvider);
await authRepository.signOut();
```

Cierra sesión tanto de Firebase como de Google Sign-In.

---

## Uso en la Aplicación

### Proteger Rutas - Detectar Usuario Autenticado

Puedes usar `authStateChangesProvider` para redirigir automáticamente:

```dart
// En main.dart o en un AuthGate widget

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        // Si hay usuario, ir a MainTabs
        if (user != null) {
          return const MainTabs();
        }
        // Si no hay usuario, mostrar LoginPage
        return const LoginPage();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

// Luego en MyApp:
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Game Rank',
    theme: ThemeData(...),
    home: const AuthGate(), // <-- Usar AuthGate en lugar de LoginPage
  );
}
```

### Obtener Usuario Actual en Cualquier Widget

```dart
class HomeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;

    if (user == null) {
      return const Text('No autenticado');
    }

    return Column(
      children: [
        Text('Email: ${user.email}'),
        Text('UID: ${user.uid}'),
        Text('Display Name: ${user.displayName ?? 'Sin nombre'}'),
        Text('Photo URL: ${user.photoURL ?? 'Sin foto'}'),

        ElevatedButton(
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
          },
          child: const Text('Cerrar Sesión'),
        ),
      ],
    );
  }
}
```

### Guardar Datos Asociados al Usuario en Firestore

```dart
Future<void> submitReview(
  String gameId,
  double rating,
  String comment,
) async {
  final user = ref.read(currentUserProvider);

  if (user == null) {
    throw Exception('Debes iniciar sesión para enviar una reseña');
  }

  await FirebaseFirestore.instance
      .collection('reviews')
      .add({
    'gameId': gameId,
    'userId': user.uid,  // <-- UID del usuario autenticado
    'userEmail': user.email,
    'rating': rating,
    'comment': comment,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
```

---

## Solución de Problemas

### 🔴 Error: "PlatformException (sign_in_failed)"

**Causa:** SHA-1 no configurado en Firebase o `google-services.json` desactualizado.

**Solución:**

1. Verifica que agregaste el SHA-1 en Firebase Console (ver [Paso 1](#paso-1-obtener-tu-sha-1))
2. Descarga el nuevo `google-services.json` (ver [Paso 4](#paso-4-descargar-nuevo-google-servicesjson))
3. Ejecuta `flutter clean && flutter pub get`
4. Reconstruye la app

### 🔴 Error: "API no habilitada en Google Cloud Console"

**Causa:** Google Sign-In no está habilitado en Firebase.

**Solución:**

1. Firebase Console → Authentication → Sign-in method
2. Habilita "Google" (ver [Paso 3](#paso-3-habilitar-google-sign-in))

### 🔴 Google Sign-In se cancela inmediatamente

**Causa:** Conflicto de SHA-1 entre debug y release.

**Solución:**
Para desarrollo, asegúrate de usar solo el SHA-1 de debug:

```bash
cd android
./gradlew signingReport | grep "SHA1"
```

Para producción, necesitarás también el SHA-1 de tu keystore de release.

### 🔴 Error: "No user record corresponding to this identifier"

**Causa:** Email no registrado.

**Solución:**

- Si es login: Verificar que el email existe en Firebase Console → Authentication → Users
- Si es Google Sign-In: Debería crear usuario automáticamente. Verifica que OAuth está habilitado.

### 🔴 Error: "The email address is already in use"

**Causa:** Intentando registrar un email que ya existe.

**Solución:**

- Cambiar a modo "Login" en lugar de "Registro"
- O usar "¿Olvidaste tu contraseña?" si no recuerdas la contraseña

---

## Comandos Útiles

### Ver logs de autenticación

```bash
adb logcat | grep -E "(flutter|FirebaseAuth|GoogleSignIn)"
```

### Verificar SHA-1 configurado

```bash
cd android
./gradlew signingReport
```

### Limpiar build completo

```bash
flutter clean
flutter pub get
flutter run
```

### Ver usuarios en Firebase

```bash
# Manualmente en:
# https://console.firebase.google.com/project/gamerank-18bd3/authentication/users
```

---

## Próximos Pasos Opcionales

### 🔹 1. Añadir Verificación de Email

```dart
// Después de registro
final user = authRepository.currentUser;
if (user != null && !user.emailVerified) {
  await user.sendEmailVerification();
  print('Email de verificación enviado');
}
```

### 🔹 2. Actualizar Perfil de Usuario

```dart
final user = authRepository.currentUser;
await user?.updateDisplayName('Nombre del Usuario');
await user?.updatePhotoURL('https://ejemplo.com/foto.jpg');
```

### 🔹 3. Eliminar Cuenta

```dart
final user = authRepository.currentUser;
await user?.delete();
```

### 🔹 4. Re-autenticación (para operaciones sensibles)

```dart
// Antes de eliminar cuenta o cambiar email
final credential = EmailAuthProvider.credential(
  email: 'usuario@ejemplo.com',
  password: 'password123',
);
await user?.reauthenticateWithCredential(credential);
```

### 🔹 5. Login con Apple (iOS)

Agregar dependencia:

```yaml
dependencies:
  sign_in_with_apple: ^6.1.3
```

### 🔹 6. Login con Facebook

Agregar dependencia:

```yaml
dependencies:
  flutter_facebook_auth: ^7.0.0
```

---

## Estructura Final de Archivos

```
lib/
├── domain/
│   └── repositories/
│       └── auth_repository.dart          ✨ NUEVO
├── data/
│   ├── datasources/
│   │   ├── firebase_auth_datasource.dart ✨ NUEVO
│   │   └── firestore_game_datasource.dart
│   └── repositories/
│       ├── firebase_auth_repository.dart ✨ NUEVO
│       └── firestore_game_repository.dart
├── providers/
│   ├── auth_providers.dart               ✨ NUEVO
│   └── providers.dart
└── pages/
    ├── login_page.dart                   📝 MODIFICADO
    └── main_tabs.dart

pubspec.yaml                              📝 MODIFICADO (google_sign_in añadido)
```

---

## Resumen

✅ **Lo que SE implementó:**

- Arquitectura MVC completa con Riverpod
- Login con email/contraseña
- Registro de usuarios
- Google Sign-In
- Recuperación de contraseña
- Manejo de errores en español
- UI con toggle login/registro
- Validaciones de formulario

⚠️ **Lo que DEBES configurar:**

- Agregar SHA-1 en Firebase Console
- Descargar nuevo google-services.json
- Habilitar Google Sign-In en Firebase

🚀 **Después de configurar:**

```bash
flutter clean
flutter pub get
flutter run
```

¡Y ya podrás autenticarte con email/contraseña y con Google! 🎮
