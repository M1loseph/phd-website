package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonProperty
import java.time.Instant
import java.util.UUID

enum class EnvironmentDto {
  @JsonProperty("pwr_server")
  PWR_SERVER,

  @JsonProperty("github_pages")
  GITHUB_PAGES,
}

data class CreateAppOpenedEventDto(
  @param:JsonProperty("eventTime") val eventTime: Instant,
  @param:JsonProperty("sessionId") val sessionId: UUID,
  @param:JsonProperty("environment") val environment: EnvironmentDto,
)
