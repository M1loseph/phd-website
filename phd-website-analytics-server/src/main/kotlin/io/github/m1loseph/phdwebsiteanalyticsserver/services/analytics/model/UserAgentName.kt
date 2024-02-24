package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

@JvmInline
value class UserAgentName(val userAgentName: String) {
  companion object {
    fun fromNullable(userAgentName: String?): UserAgentName? {
      return if (userAgentName == null) {
        null
      } else {
        UserAgentName(userAgentName)
      }
    }
  }
}
