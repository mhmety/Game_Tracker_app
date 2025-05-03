buildscript {
    repositories {
        google()  // Google servislerini çözümleyebilmesi için gerekli
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.2.2") // Gradle plugin sürümü
        classpath("com.google.gms:google-services:4.3.15")  // Firebase için Google Services plugin
    }
}

allprojects {
    repositories {
        google()  // Google servislerine erişebilmek için bu repository gerekli
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")  // App modülüne bağlı projeleri değerlendirmek için
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
