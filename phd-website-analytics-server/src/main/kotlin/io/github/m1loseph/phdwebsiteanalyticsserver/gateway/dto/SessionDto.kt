package io.github.m1loseph.phdwebsiteanalyticsserver.gateway.dto

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.PageNameDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.SessionIdDto
import java.time.Instant

data class SessionDto(
  val sessionId: SessionIdDto,
  val pageOpenings: List<PageOpenedEventDto>,
)

data class PageOpenedEventDto(
  val pageName: PageNameDto,
  val userTime: Instant,
  val serverTime: Instant,
)
