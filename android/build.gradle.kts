allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureAndroid = {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    val ns = if (project.name == "isar_flutter_libs") {
                        "dev.isar.isar_flutter_libs"
                    } else {
                        project.group.toString()
                    }
                    setNamespace.invoke(android, ns)
                }
            } catch (e: Exception) {
                // Ignore if not a standard Android project
            }
            // Force compileSdkVersion = 36 on all plugins (fixes isar_flutter_libs lStar error)
            try {
                val setCompileSdk = android.javaClass.getMethod("compileSdkVersion", Int::class.java)
                setCompileSdk.invoke(android, 36)
            } catch (e: Exception) {
                // Ignore if method signature differs
            }
        }
    }

    if (project.state.executed) {
        configureAndroid()
    } else {
        project.afterEvaluate {
            configureAndroid()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
