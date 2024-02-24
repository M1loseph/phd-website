package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonProperty
import java.time.Instant
import java.util.UUID

data class CreateAppOpenedEventDto(
    @param:JsonProperty("eventTime") val eventTime: Instant,
    @param:JsonProperty("sessionId") val sessionId: UUID,
)
