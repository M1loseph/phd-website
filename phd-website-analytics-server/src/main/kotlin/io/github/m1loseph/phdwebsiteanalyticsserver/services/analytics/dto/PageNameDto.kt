package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonProperty

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