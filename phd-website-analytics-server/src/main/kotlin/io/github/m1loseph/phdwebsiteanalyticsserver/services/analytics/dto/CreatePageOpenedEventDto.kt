package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonProperty
import java.time.Instant

data class CreatePageOpenedEventDto(
  @param:JsonProperty("pageName") val pageName: PageNameDto,
  @param:JsonProperty("eventTime") val eventTime: Instant,
  @param:JsonProperty("sessionId") val sessionId: UUID,
)
