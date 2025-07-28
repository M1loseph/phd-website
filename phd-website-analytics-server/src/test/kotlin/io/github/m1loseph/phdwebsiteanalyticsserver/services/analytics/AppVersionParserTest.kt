package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppVersion
import org.assertj.core.api.Assertions
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.Arguments
import org.junit.jupiter.params.provider.MethodSource

class AppVersionParserTest {
  @ParameterizedTest
  @MethodSource("implementationsToTest")
  fun shouldParseSimpleVersionWithMajorAndMinor(parser: AppVersionParser) {
    val version = parser.parse("1.2")
    assertThat(version).isEqualTo(
      AppVersion(
        major = 1,
        minor = 2,
        rawVersion = "1.2",
      ),
    )
  }

  @ParameterizedTest
  @MethodSource("implementationsToTest")
  fun shouldParseVersionWithTwoDigits(parser: AppVersionParser) {
    val version = parser.parse("11.22")
    assertThat(version).isEqualTo(
      AppVersion(
        major = 11,
        minor = 22,
        rawVersion = "11.22",
      ),
    )
  }

  @ParameterizedTest
  @MethodSource("implementationsToTest")
  fun shouldParseVersionWithCommitsCountAndCommitHash(parser: AppVersionParser) {
    val version = parser.parse("11.22-2-gabdef1123")
    assertThat(version).isEqualTo(
      AppVersion(
        major = 11,
        minor = 22,
        commitsAheadOfTag = 2,
        commitHash = "abdef1123",
        rawVersion = "11.22-2-gabdef1123",
      ),
    )
  }

  @ParameterizedTest
  @MethodSource("invalidVersionArguments")
  fun whenInvalidVersionIsProvided_thenShouldFailParsingWithAnAppropriateException(
    parser: AppVersionParser,
    invalidString: String,
  ) {
    Assertions
      .assertThatThrownBy { parser.parse(invalidString) }
      .isExactlyInstanceOf(InvalidVersionException::class.java)
  }

  companion object {
    @JvmStatic
    fun implementationsToTest(): List<AppVersionParser> = listOf(RegexAppVersionParser(), ManualAppVersionParser())

    @JvmStatic
    fun invalidVersionArguments(): List<Arguments> {
      val implementations = implementationsToTest()
      val invalidVersions =
        listOf(
          "11.",
          "",
          "a",
          "12.a",
          "9-",
          "1.-",
          "1.1--abcd",
          "9.9-1-",
          "9.9-1-g",
          "10.10-1-g12345678u",
          "12.12-1-0bd1235876",
          "12.12-1-g" + "a".repeat(41),
        )

      return implementations.flatMap { parser -> invalidVersions.map { version -> Arguments.of(parser, version) } }
    }
  }
}
