package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import jakarta.validation.constraints.Positive
import jakarta.validation.constraints.Size
import java.time.Instant

enum class EnvironmentDto {
  @JsonProperty("pwr_server")
  PWR_SERVER,

  @JsonProperty("github_pages")
  GITHUB_PAGES,
}

data class DeviceMetadataDto(
  @Positive val screenWidth: Int,
  @Positive val screenHeight: Int,
)

@JsonIgnoreProperties(ignoreUnknown = true)
data class CreateAppOpenedEventDto(
  val eventTime: Instant,
  val environment: EnvironmentDto,
  val deviceMetadata: DeviceMetadataDto,
  @Size(min = 3, max = 100) val appVersion: String,
)
