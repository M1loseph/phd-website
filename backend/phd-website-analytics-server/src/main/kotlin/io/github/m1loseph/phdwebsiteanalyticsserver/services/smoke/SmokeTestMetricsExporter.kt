package io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke

import io.micrometer.core.instrument.MeterRegistry
import io.micrometer.core.instrument.Tag
import org.springframework.stereotype.Component

@Component
class SmokeTestMetricsExporter(smokeTestsService: SmokeTestsService, meterRegistry: MeterRegistry) {
  private val mongodbWorkingGauge =
      meterRegistry.gauge(
          "tests.smoke", listOf(Tag.of("dependency", "mongodb")), smokeTestsService) {
            when (it.testIfConnectionToMongodbIsAlive()) {
              SmokeTestResult.OK -> 0.0
              SmokeTestResult.ERROR -> 1.0
            }
          }

  private val redisWorkingGauge =
      meterRegistry.gauge("tests.smoke", listOf(Tag.of("dependency", "redis")), smokeTestsService) {
        when (it.testIfConnectionToMongodbIsAlive()) {
          SmokeTestResult.OK -> 0.0
          SmokeTestResult.ERROR -> 1.0
        }
      }
}
