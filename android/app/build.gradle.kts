plugins {
    id("com.android.application")
    // Plugin de Firebase (necesario para analytics, auth, firestore, etc.)
    id("com.google.gms.google-services")
    id("kotlin-android")
    // Flutter plugin (debe ir al final)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.game_rank"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Habilitar desugaring para flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.game_rank"
        minSdk = flutter.minSdkVersion          // <- IMPORTANTE para Firebase
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring para flutter_local_notifications (requiere 2.1.4+)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
