package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppVersion

class InvalidVersionException(
  val version: String,
  message: String,
) : RuntimeException(message)

interface AppVersionParser {
  @Throws(InvalidVersionException::class)
  fun parse(version: String): AppVersion
}

class ManualAppVersionParser : AppVersionParser {
  override fun parse(version: String): AppVersion {
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
          throw InvalidVersionException(version, "Unable to parse major version")
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
          throw InvalidVersionException(version, "Unable to parse minor version")
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
          throw InvalidVersionException(version, "Unable to parse commits count")
        }

        ParsingStep.HASH -> {
          val hashValue = version.substring(previousSectionEnd + 1, version.length)
          if (hashValue.length > 40) {
            throw InvalidVersionException(version, "Version hash is too long")
          }
          if (hashValue.length <= 1) {
            throw InvalidVersionException(version, "Version hash is too short")
          }
          for ((j, letter) in hashValue.withIndex()) {
            if (j == 0 && letter != 'g') {
              throw InvalidVersionException(version, "Version hash should start with g")
            }
            if (j > 0 && !letter.isDigit() && letter !in 'a'..'f') {
              throw InvalidVersionException(version, "Version hash contains invalid hex characters")
            }
          }
          hash = hashValue.substring(1)
          parsingStep = ParsingStep.END
        }

        ParsingStep.END -> break
      }
    }

    if (parsingStep != ParsingStep.END) {
      throw InvalidVersionException(version, "Unable to parse version")
    }

    return AppVersion(major!!, minor!!, commitsAheadOfTag, hash, version)
  }
}

enum class ParsingStep {
  MAJOR,
  MINOR,
  COMMITS_COUNT,
  HASH,
  END,
}

class RegexAppVersionParser : AppVersionParser {
  override fun parse(version: String): AppVersion {
    val result = regex.matchEntire(version)
    if (result == null) {
      throw InvalidVersionException(version, "Can't parse version")
    }
    val majorVersion = result.groups[MAJOR_VERSION_GROUP]!!.value.toInt()
    val minorVersion = result.groups[MINOR_VERSION_GROUP]!!.value.toInt()
    val commitsAheadOfTag = result.groups[COMMIT_AHEAD_OF_TAG_GROUP]?.value?.toInt()
    val commitHash = result.groups[COMMIT_HASH_GROUP]?.value

    return AppVersion(
      major = majorVersion,
      minor = minorVersion,
      commitsAheadOfTag = commitsAheadOfTag,
      commitHash = commitHash,
      rawVersion = version,
    )
  }

  companion object {
    val regex = Regex("""^(\d+)\.(\d+)(-(\d+)-g([0-9a-f]{2,39}))?$""")

    const val MAJOR_VERSION_GROUP = 1
    const val MINOR_VERSION_GROUP = 2
    const val COMMIT_AHEAD_OF_TAG_GROUP = 4
    const val COMMIT_HASH_GROUP = 5
  }
}
