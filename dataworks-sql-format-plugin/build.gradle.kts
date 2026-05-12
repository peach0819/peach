plugins {
    id("java")
    id("org.jetbrains.intellij") version "1.17.4"
}

group = "com.peach"
version = "1.0.0"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.9.2")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

intellij {
    version.set("2021.3")
    type.set("IC")
    plugins.set(listOf())
}

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

tasks {
    withType<JavaCompile> {
        options.encoding = "UTF-8"
    }
    patchPluginXml {
        sinceBuild.set("213")
        untilBuild.set("241.*")
    }
    buildSearchableOptions {
        enabled = false
    }
    test {
        useJUnitPlatform()
    }
}
