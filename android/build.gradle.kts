// The Android Gradle Plugin builds the native code with the Android NDK.

group = "org.sjrobinsonconsulting.llamacpp"
version = "1.0"

buildscript {
    repositories {
        google()
        mavenCentral()
		gradlePluginPortal()
    }

    dependencies {
        // The Android Gradle Plugin knows how to build native code with the NDK.
        classpath("com.android.tools.build:gradle:8.9.0")
    }
}

allprojects {
    repositories {
        google()
        jcenter()
    }
}

plugins {
    id("com.android.library")
	id("org.jetbrains.kotlin.android")
}

android {
    namespace = "org.sjrobinsonconsulting.llamacpp"

    // Bumping the plugin compileSdk version requires all clients of this plugin
    // to bump the version in their app.
    compileSdk = 32

    // Use the NDK version
    // declared in /android/app/build.gradle file of the Flutter project.
    // Replace it with a version number if this plugin requires a specific NDK version.
    // (e.g. ndkVersion "23.1.7779620")
    ndkVersion = android.ndkVersion

    // Invoke the shared CMake build with the Android Gradle Plugin.
    externalNativeBuild {
        cmake {
            path = file("./CMakeLists.txt")

            // The default CMake version for the Android Gradle Plugin is 3.10.2.
            // https://developer.android.com/studio/projects/install-ndk#vanilla_cmake
            //
            // The Flutter tooling requires that developers have CMake 3.10 or later
            // installed. You should not increase this version, as doing so will cause
            // the plugin to fail to compile for some customers of the plugin.
            // version "3.10.2"
        }
    }
	
	compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
        minSdk = 32
        targetSdk = 33
    }
}
