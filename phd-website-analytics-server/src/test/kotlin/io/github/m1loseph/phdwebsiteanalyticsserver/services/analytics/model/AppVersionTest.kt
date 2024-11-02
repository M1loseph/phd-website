package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

import org.assertj.core.api.Assertions
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource

class AppVersionTest {
  @Test
  fun shouldParseSimpleVersionWithMajorAndMinor() {
    val version = AppVersion.parse("1.2")
    assertThat(version).isEqualTo(
      AppVersion(
        major = 1,
        minor = 2,
        rawVersion = "1.2",
      ),
    )
  }

  @Test
  fun shouldParseVersionWithTwoDigits() {
    val version = AppVersion.parse("11.22")
    assertThat(version).isEqualTo(
      AppVersion(
        major = 11,
        minor = 22,
        rawVersion = "11.22",
      ),
    )
  }

  @Test
  fun shouldParseVersionWithCommitsCountAndCommitHash() {
    val version = AppVersion.parse("11.22-2-abdefghijk")
    assertThat(version).isEqualTo(
      AppVersion(
        major = 11,
        minor = 22,
        commitsAheadOfTag = 2,
        commitHash = "abdefghijk",
        rawVersion = "11.22-2-abdefghijk",
      ),
    )
  }

  @ParameterizedTest
  @ValueSource(strings = ["11.", "", "a", "12.a", "9-", "1.-", "1.1--abcd", "9.9-1-", "10.10-1-12345678u"])
  fun whenInvalidVersionIsProvided_thenShouldFailParsingWithAnAppropriateException(invalidString: String) {
    Assertions.setMaxStackTraceElementsDisplayed(50)
    assertThatThrownBy { AppVersion.parse(invalidString) }
      .isExactlyInstanceOf(InvalidVersionException::class.java)
  }
}
