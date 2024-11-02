import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
  id("org.springframework.boot") version "3.2.2"
  id("io.spring.dependency-management") version "1.1.4"
  kotlin("jvm") version "1.9.22"
  kotlin("plugin.spring") version "1.9.22"

  // Custom plugins
  id("com.diffplug.spotless") version "6.25.0"
  id("com.google.cloud.tools.jib") version "3.4.1"
}

group = "io.github.m1loseph"

java {
  sourceCompatibility = JavaVersion.VERSION_21
}

repositories {
  mavenCentral()
}

dependencies {
  implementation("org.springframework.boot:spring-boot-starter-webflux")
  implementation("io.projectreactor.kotlin:reactor-kotlin-extensions")
  implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
  implementation("org.springframework.boot:spring-boot-starter-validation")
  implementation("org.springframework.boot:spring-boot-starter-actuator")
  implementation("org.springframework.boot:spring-boot-starter-data-mongodb-reactive")
  implementation("io.micrometer:micrometer-registry-prometheus")

  implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
  implementation("jakarta.validation:jakarta.validation-api")

  implementation("redis.clients:jedis:5.1.0")

  implementation("org.jetbrains.kotlin:kotlin-reflect")

  testImplementation("org.springframework.boot:spring-boot-starter-test") {
    exclude(group = "com.vaadin.external.google", module = "android-json")
  }
  testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test")
  testImplementation("io.projectreactor:reactor-test")
  testImplementation("org.testcontainers:junit-jupiter:1.19.7")
  testImplementation("org.mockito.kotlin:mockito-kotlin:5.2.1")
}

tasks.withType<KotlinCompile> {
  kotlinOptions {
    freeCompilerArgs += "-Xjsr305=strict"
    jvmTarget = "21"
  }
}

spotless {
  kotlin {
    ktlint()
  }
}

// TODO: write a dependOn for jib tasks and build tasks on spotless

tasks.withType<Test> {
  useJUnitPlatform()
}

jib {
  from {
    image = "eclipse-temurin:21-jre-noble"
    platforms {
      platform {
        os = "linux"
        architecture = "arm64"
      }
      platform {
        os = "linux"
        architecture = "amd64"
      }
    }
  }
  to {
    image = "m1loseph/phd-website-analytics-server"
    tags = setOf("$version")
  }
  container {
    ports = listOf("8080")
  }
}
