package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

import org.openjdk.jmh.annotations.Benchmark
import org.openjdk.jmh.infra.Blackhole

open class AppVersionParsingBenchmark {

  @Benchmark
  fun benchmarkParsingLongVersion(blackHole: Blackhole) {
    val appVersion = AppVersion.parse(APP_VERSION_WITH_ABBREV)
    blackHole.consume(appVersion)
  }

  companion object {
    const val APP_VERSION_WITH_ABBREV = "123.23-30-g6a0036e"
  }
}