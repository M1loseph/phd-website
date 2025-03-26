package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.SessionId
import java.util.UUID

@JvmInline
value class SessionIdDto(
  val value: UUID,
) {
  companion object {
    fun fromModel(sessionId: SessionId) = SessionIdDto(value = sessionId.rawValue)
  }
}

data class AppOpenedEventResponse(
  val sessionId: String,
)
