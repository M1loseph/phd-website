import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
  alias(libs.plugins.spring.plugin)
  alias(libs.plugins.kotlin.jvm)
  alias(libs.plugins.kotlin.spring)

  // Custom plugins
  alias(libs.plugins.jmh)
  alias(libs.plugins.spotless)
  alias(libs.plugins.jib)
}

group = "io.github.m1loseph"
version = calculateVersion()

repositories {
  mavenCentral()
}

kotlin {
  jvmToolchain(21)
}

dependencies {
  implementation(platform(org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES))
  implementation(libs.spring.boot.starter.webflux)
  implementation(libs.reactor.kotlin.extensions)
  implementation(libs.jackson.module.kotlin)
  implementation(libs.spring.boot.starter.validation)
  implementation(libs.spring.boot.starter.actuator)
  implementation(libs.spring.boot.starter.data.mongodb.reactive)
  implementation(libs.micrometer.registry.prometheus)

  implementation(libs.kotlinx.coroutines.reactor)
  implementation(libs.jakarta.validation.api)

  implementation(libs.jedis)


  testImplementation(libs.spring.boot.starter.test)
  testImplementation(libs.kotlinx.coroutines.test)
  testImplementation(libs.reactor.test)
  testImplementation(libs.test.containers)
  testImplementation(libs.mockito.kotlin)
}

tasks.withType<KotlinCompile> {
  compilerOptions {
    allWarningsAsErrors = true
    freeCompilerArgs.addAll("-Xjsr305=strict", "-Xannotation-default-target=param-property")
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
