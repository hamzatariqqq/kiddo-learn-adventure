import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        FileInputStream(keystorePropertiesFile)
    )
}

android {
    namespace = "com.zynax.kiddo_learn"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.zynax.kiddo_learn"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile =
                keystoreProperties["storeFile"]?.let {
                    file(it)
                }
            storePassword =
                keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName("release")

            // Temporarily disable R8 optimization
            // until real-phone startup is stable.
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    implementation(
        "com.google.android.gms:play-services-ads:25.4.0"
    )

    implementation(
        "androidx.work:work-runtime:2.11.2"
    )

    implementation(
        "androidx.startup:startup-runtime:1.2.0"
    )
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

apply(plugin = "com.google.gms.google-services")