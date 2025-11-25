package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

data class UserSession(
  val appOpenedEvent: AppOpenedEvent,
  val pageOpenedEvents: List<PageOpenedEvent>,
)
