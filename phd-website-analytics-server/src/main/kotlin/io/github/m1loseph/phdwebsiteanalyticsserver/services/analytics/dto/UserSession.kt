package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto

import java.time.Instant

data class UserSession(
  val sessionId: String,
  val environment: EnvironmentDto,
  val visitedPages: List<VisitedPage>,
)

data class VisitedPage(
  val page: PageNameDto,
  val visitedTime: Instant,
)
