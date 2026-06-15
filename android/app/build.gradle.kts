plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tourist_safety_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    
    allprojects {
        tasks.withType<JavaCompile> {
            options.compilerArgs.add("-Xlint:-options")
        }
    }


    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.tourist_safety_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    // android.applicationVariants.all {
    // val variant = this

    // variant.outputs.all {
    //     val date = SimpleDateFormat("yyyyMMdd").format(Date())

    //     val version = variant.versionName ?: "0.0.0"

    //     // Extract stage from version string
    //     val stage = when {
    //         version.contains("alpha", ignoreCase = true) -> "alpha"
    //         version.contains("beta", ignoreCase = true) -> "beta"
    //         version.contains("rc", ignoreCase = true) -> "rc"
    //         else -> "stable"
    //     }

    //     val cleanVersion = version
    //         .replace("-alpha", "")
    //         .replace("-beta", "")
    //         .replace("-rc", "")

    //     (this as BaseVariantOutputImpl).outputFileName =
    //         "TouriSafe_v${cleanVersion}_${stage}_${variant.buildType.name}_${date}.apk"
    //     }
    // }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
