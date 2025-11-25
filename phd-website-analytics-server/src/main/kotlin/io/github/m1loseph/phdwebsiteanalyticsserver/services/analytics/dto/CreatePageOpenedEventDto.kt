package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageName
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

  ;

  companion object {
    fun fromModel(pageName: PageName): PageNameDto =
      when (pageName) {
        PageName.HOME -> HOME
        PageName.CONTACT -> CONTACT
        PageName.CONSULTATION -> CONSULTATION
        PageName.RESEARCH -> RESEARCH
        PageName.TEACHING -> TEACHING
      }
  }
}

@JsonIgnoreProperties(ignoreUnknown = true)
data class CreatePageOpenedEventDto(
  val pageName: PageNameDto,
  val eventTime: Instant,
  val sessionId: SessionIdDto,
)
