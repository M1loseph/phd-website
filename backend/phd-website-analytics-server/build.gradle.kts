import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
  id("org.springframework.boot") version "3.2.2"
  id("io.spring.dependency-management") version "1.1.4"
  kotlin("jvm") version "1.9.22"
  kotlin("plugin.spring") version "1.9.22"

  // Custom plugins
  id("com.diffplug.spotless") version "6.25.0"
}

group = "io.github.m1loseph"
// TODO: use a dedicated technique to version this app
version = "0.0.1-SNAPSHOT"

java {
  sourceCompatibility = JavaVersion.VERSION_21
}

repositories {
  mavenCentral()
}

dependencies {
  implementation("org.springframework.boot:spring-boot-starter")
  implementation("org.springframework.boot:spring-boot-starter-web")
  implementation("org.springframework.boot:spring-boot-starter-validation")
  implementation("org.springframework.boot:spring-boot-starter-actuator")
  implementation("org.springframework.boot:spring-boot-starter-data-mongodb")
  implementation("io.micrometer:micrometer-registry-prometheus")

  // Required in order to use validation API. Without this dependency annotations are not available.
  implementation("jakarta.validation:jakarta.validation-api:3.0.2")

  // Rate limiting library and dependency to handle persistence
  implementation("com.bucket4j:bucket4j-core:8.7.1")
  implementation("com.bucket4j:bucket4j-redis:8.7.1")
  implementation("redis.clients:jedis:5.1.0")

  implementation("org.jetbrains.kotlin:kotlin-reflect")

  testImplementation("org.springframework.boot:spring-boot-starter-test") {
    exclude(group = "com.vaadin.external.google", module = "android-json")
  }
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
    ktfmt()
  }
}

tasks.withType<Test> {
  useJUnitPlatform()
}
