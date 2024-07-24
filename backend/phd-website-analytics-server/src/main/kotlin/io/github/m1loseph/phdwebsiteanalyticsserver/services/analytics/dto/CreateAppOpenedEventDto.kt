package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonProperty
import java.time.Instant

enum class EnvironmentDto {
  @JsonProperty("pwr_server")
  PWR_SERVER,

  @JsonProperty("github_pages")
  GITHUB_PAGES,
}

data class CreateAppOpenedEventDto(
  @param:JsonProperty("eventTime") val eventTime: Instant,
  @param:JsonProperty("environment") val environment: EnvironmentDto,
)
