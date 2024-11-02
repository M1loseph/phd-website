package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

import org.slf4j.LoggerFactory

class InvalidVersionException(message: String) : RuntimeException(message)

data class AppVersion(val major: Int,
                      val minor: Int,
                      val commitsAheadOfTag: Int? = null,
                      val commitHash: String? = null,
                      val rawVersion: String
) {
  companion object {
    private val logger = LoggerFactory.getLogger(AppVersion::class.java)

    // TODO: write a version with splitting and compare performance
    fun parse(version: String): AppVersion {
      if (version.isEmpty()) {
        logger.error("Version string is empty")
        throw InvalidVersionException("Version is empty")
      }
      if (version.length > 50) {
        logger.error("Version is too long")
        throw InvalidVersionException("Version is too long. Length: ${version.length}")
      }

      var previousSectionEnd = 0
      var major: Int? = null
      var minor: Int? = null
      var commitsAheadOfTag: Int? = null
      var hash: String? = null

      var parsingStep = ParsingStep.MAJOR

      for ((i, character) in version.withIndex()) {
        when (parsingStep) {
          ParsingStep.MAJOR -> {
            if (character.isDigit()) {
              continue
            }
            if (character == '.' && i > 0) {
              major = version.substring(0, i).toInt()
              previousSectionEnd = i
              parsingStep = ParsingStep.MINOR
              continue
            }
            throw InvalidVersionException("Unable to parse major version in version: $version")
          }

          ParsingStep.MINOR -> {
            val isEnd = i + 1 == version.length
            if (character.isDigit() && !isEnd) {
              continue
            }
            if (character.isDigit() && isEnd) {
              minor = version.substring(previousSectionEnd + 1, i + 1).toInt()
              parsingStep = ParsingStep.END
              continue
            }
            val minorVersionLength = i - previousSectionEnd - 1
            if (character == '-' && minorVersionLength > 0) {
              minor = version.substring(previousSectionEnd + 1, i).toInt()
              parsingStep = ParsingStep.COMMITS_COUNT
              previousSectionEnd = i
              continue
            }
            throw InvalidVersionException("Unable to parse minor version in version: $version")
          }

          ParsingStep.COMMITS_COUNT -> {
            if (character.isDigit()) {
              continue
            }
            val commitsCountLength = i - previousSectionEnd - 1
            if (character == '-' && commitsCountLength > 0) {
              commitsAheadOfTag = version.substring(previousSectionEnd + 1, i).toInt()
              parsingStep = ParsingStep.HASH
              previousSectionEnd = i
              continue
            }
            throw InvalidVersionException("TODO")
          }

          ParsingStep.HASH -> {
            hash = version.substring(previousSectionEnd + 1, version.length)
            parsingStep = ParsingStep.END
          }

          ParsingStep.END -> {
            break
          }
        }
      }

      if (parsingStep != ParsingStep.END) {
        throw InvalidVersionException("TODO")
      }

      return AppVersion(major!!, minor!!, commitsAheadOfTag, hash, version)
    }
  }
}

enum class ParsingStep {
  MAJOR, MINOR, COMMITS_COUNT, HASH, END
}