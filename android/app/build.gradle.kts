plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.game_tracker_app"  // Firebase ile uyumlu olmalı
    compileSdk = 35  // En son SDK sürümü
    ndkVersion = "27.0.12077973"  // Firebase ile uyumlu NDK sürümü

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.game_tracker_app"  // Firebase ile uyumlu olmalı
        minSdk = 21
        targetSdk = 35  // En son SDK sürümü
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
    source = "../.."  // Flutter projesi dizini
}
