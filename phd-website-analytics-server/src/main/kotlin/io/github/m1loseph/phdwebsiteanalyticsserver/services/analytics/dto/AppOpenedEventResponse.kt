package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonProperty

data class AppOpenedEventResponse(
  @param:JsonProperty("sessionId") val sessionId: String,
)
