package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import java.time.Instant

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

@JsonIgnoreProperties(ignoreUnknown = true)
data class CreatePageOpenedEventDto(
  val pageName: PageNameDto,
  val eventTime: Instant,
  val sessionId: SessionIdDto,
)
