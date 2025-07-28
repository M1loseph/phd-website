package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import jakarta.validation.constraints.Size
import java.time.Instant

enum class EnvironmentDto {
  @JsonProperty("pwr_server")
  PWR_SERVER,

  @JsonProperty("github_pages")
  GITHUB_PAGES,
}

@JsonIgnoreProperties(ignoreUnknown = true)
data class CreateAppOpenedEventDto(
  val eventTime: Instant,
  val environment: EnvironmentDto,
  @Size(min = 5, max = 100) val appVersion: String?,
)
