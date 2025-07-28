import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
  id("org.springframework.boot") version "3.5.4"
  kotlin("jvm") version "2.2.0"
  kotlin("plugin.spring") version "2.2.0"

  // Custom plugins
  id("me.champeau.jmh") version "0.7.2"
  id("com.diffplug.spotless") version "7.0.2"
  id("com.google.cloud.tools.jib") version "3.4.5"
}

group = "io.github.m1loseph"
version = calculateVersion()

repositories {
  mavenCentral()
}

dependencies {
  implementation(platform(org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES))
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
  testImplementation("org.testcontainers:junit-jupiter:1.20.3")
  testImplementation("org.mockito.kotlin:mockito-kotlin:5.2.1")
}

tasks.withType<KotlinCompile> {
  compilerOptions {
    allWarningsAsErrors = true
    freeCompilerArgs.addAll("-Xjsr305=strict", "-Xannotation-default-target=param-property")
    jvmTarget = JvmTarget.JVM_21
  }
}

spotless {
  kotlin {
    ktlint()
  }
}

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

fun calculateVersion(): String {
  val process = ProcessBuilder(
    "git",
    "describe",
    "--tags",
    "--match",
    "analytics-server/**",
  ).start()
  if (!process.waitFor(10, TimeUnit.SECONDS)) {
    throw Exception("It took more than 10 seconds for git command to complete")
  }
  val exitCode = process.exitValue()
  if (exitCode != 0) {
    val stderr = String(process.errorStream.readAllBytes()).trim()
    throw Exception("Git exit code is different than 0. Stderr output: $stderr")
  }
  val gitResult = String(process.inputStream.readAllBytes()).trim()
  val actualVersion = gitResult.split("/", limit = 2)[1]
  println("Project version is $actualVersion")
  return actualVersion
}
