package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonProperty
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.SessionId
import java.util.UUID

@JvmInline
value class SessionIdDto(val sessionId: UUID) {
  companion object {
    fun fromModel(sessionId: SessionId) = SessionIdDto(sessionId = sessionId.rawValue)
  }
}

data class AppOpenedEventResponse(
  @param:JsonProperty("sessionId") val sessionId: String,
)
