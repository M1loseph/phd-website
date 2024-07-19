package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonProperty
import java.time.Instant
import java.util.UUID

enum class PageNameDto {
  @JsonProperty("home")
  HOME,

  @JsonProperty("contact")
  CONTACT,

  @JsonProperty("consultation")
  CONSULTATION,

  @JsonProperty("research")
  RESEARCH,

  @JsonProperty("teaching")
  TEACHING,
}

data class CreatePageOpenedEventDto(
  @param:JsonProperty("pageName") val pageName: PageNameDto,
  @param:JsonProperty("eventTime") val eventTime: Instant,
  @param:JsonProperty("sessionId") val sessionId: UUID,
)
