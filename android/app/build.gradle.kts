// android/app/build.gradle.kts
import java.io.FileInputStream
import java.util.Properties

// 1. Read the properties file at the top of your build.gradle.kts
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.alphaagentssuite.netscope"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.alphaagentssuite.netscope"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"] as? String
            storeFile = if (!storeFilePath.isNullOrEmpty()) file(storeFilePath) else null
            storePassword = keystoreProperties["storePassword"] as? String
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
        }
    }

    buildTypes {
        getByName("release") {
            // 3. Assign the release signing config
            signingConfig = signingConfigs.getByName("release")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
}
