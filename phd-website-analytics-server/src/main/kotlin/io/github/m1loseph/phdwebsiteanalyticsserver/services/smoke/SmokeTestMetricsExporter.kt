package io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke

import io.micrometer.core.instrument.MeterRegistry
import io.micrometer.core.instrument.Tag
import kotlinx.coroutines.runBlocking
import org.springframework.stereotype.Component

@Component
class SmokeTestMetricsExporter(smokeTestsService: SmokeTestsService, meterRegistry: MeterRegistry) {
  private val mongodbWorkingGauge =
    meterRegistry.gauge("tests.smoke", listOf(Tag.of("dependency", "mongodb")), smokeTestsService) {
      when (runBlocking { it.testIfConnectionToMongodbIsAlive() }) {
        SmokeTestResult.OK -> SMOKE_TEST_SUCCESS
        SmokeTestResult.ERROR -> SMOKE_TEST_FAIL
      }
    }

  private val redisWorkingGauge =
    meterRegistry.gauge("tests.smoke", listOf(Tag.of("dependency", "redis")), smokeTestsService) {
      when (it.testIfConnectionToRedisIsAlive()) {
        SmokeTestResult.OK -> SMOKE_TEST_SUCCESS
        SmokeTestResult.ERROR -> SMOKE_TEST_FAIL
      }
    }

  companion object {
    const val SMOKE_TEST_SUCCESS = 0.0
    const val SMOKE_TEST_FAIL = 1.0
  }
}
