package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.ManualAppVersionParser
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.RegexAppVersionParser
import org.openjdk.jmh.annotations.Benchmark
import org.openjdk.jmh.annotations.BenchmarkMode
import org.openjdk.jmh.annotations.Fork
import org.openjdk.jmh.annotations.Mode
import org.openjdk.jmh.annotations.OutputTimeUnit
import org.openjdk.jmh.annotations.Scope
import org.openjdk.jmh.annotations.State
import org.openjdk.jmh.infra.Blackhole
import java.util.concurrent.TimeUnit


@Fork(1)
@State(Scope.Benchmark)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
open class AppVersionParsersBenchmark {

  val regexParser = RegexAppVersionParser()
  val manualParser = ManualAppVersionParser()

  var appVersionWithAbbreviation = "123.23-30-g6a0036e"

  @Benchmark
  fun benchmarkParsingUsingRegexParser(blackHole: Blackhole) {
    val appVersion = regexParser.parse(appVersionWithAbbreviation)
    blackHole.consume(appVersion)
  }

  @Benchmark
  fun benchmarkParsingUsingManualParser(blackHole: Blackhole) {
    val appVersion = manualParser.parse(appVersionWithAbbreviation)
    blackHole.consume(appVersion)
  }
}
