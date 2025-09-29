import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.firebase-perf")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Corrected logic to read properties
val keyProperties = Properties()
// The key.properties file is located in the `android` folder, which is the rootProject for this gradle build.
val keyPropertiesFile = rootProject.file("key.properties") 
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { input ->
        keyProperties.load(input)
    }
}

android {
    namespace = "store.gogama.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    signingConfigs {
        create("release") {
            // The keystore file is in `android/app`
            val storeFilePath = keyProperties.getProperty("storeFile")
            if (storeFilePath != null) {
                storeFile = rootProject.file("app/$storeFilePath")
            }
            storePassword = keyProperties.getProperty("storePassword")
            keyAlias = keyProperties.getProperty("keyAlias")
            keyPassword = keyProperties.getProperty("keyPassword")
        }
    }

    defaultConfig {
        applicationId = "store.gogama.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
