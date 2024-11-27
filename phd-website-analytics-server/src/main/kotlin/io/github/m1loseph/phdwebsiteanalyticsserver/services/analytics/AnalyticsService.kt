package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.CreateAppOpenedEventDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.CreatePageOpenedEventDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.EnvironmentDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.PageNameDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.UserSession
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.VisitedPage
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppVersion
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.Environment
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageName
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.SessionId
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.UserAgentName
import kotlinx.coroutines.reactor.awaitSingle
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.Instant
import java.util.UUID

@Service
class AnalyticsService(
  private val appOpenedEventRepository: AppOpenedEventRepository,
  private val pageOpenedEventRepository: PageOpenedEventRepository,
  private val serverClock: Clock,
) {
  suspend fun persistAppOpenedEvent(
    createAppOpenedEventDto: CreateAppOpenedEventDto,
    userAgent: UserAgentName?,
  ): SessionId {
    val sessionId = SessionId(UUID.randomUUID())
    val appVersion =
      if (createAppOpenedEventDto.appVersion == null) {
        null
      } else {
        AppVersion.parse(createAppOpenedEventDto.appVersion)
      }
    val entity =
      AppOpenedEvent(
        eventTime = createAppOpenedEventDto.eventTime,
        insertedAt = serverClock.instant(),
        userAgent = userAgent,
        sessionId = sessionId,
        environment =
        when (createAppOpenedEventDto.environment) {
          EnvironmentDto.PWR_SERVER -> Environment.PWR_SERVER
          EnvironmentDto.GITHUB_PAGES -> Environment.GITHUB_PAGES
        },
        appVersion = appVersion,
      )
    logger.info("Saving AppOpenedEvent event: {}", entity)
    appOpenedEventRepository.save(entity).awaitSingle()
    return sessionId
  }

  suspend fun persistPageOpenedEvent(
    createPageOpenedEventDto: CreatePageOpenedEventDto,
    userAgent: UserAgentName?,
  ): PageOpenedEvent {
    val sessionId = SessionId(createPageOpenedEventDto.sessionId)
    if (!appOpenedEventRepository.existsBySessionId(sessionId).awaitSingle()) {
      throw SessionNotFoundException("Session ${sessionId.rawValue} was not established yet")
    }
    val entity =
      PageOpenedEvent(
        eventTime = createPageOpenedEventDto.eventTime,
        pageName =
        when (createPageOpenedEventDto.pageName) {
          PageNameDto.HOME -> PageName.HOME
          PageNameDto.CONTACT -> PageName.CONTACT
          PageNameDto.CONSULTATION -> PageName.CONSULTATION
          PageNameDto.RESEARCH -> PageName.RESEARCH
          PageNameDto.TEACHING -> PageName.TEACHING
        },
        insertedAt = serverClock.instant(),
        sessionId = SessionId(createPageOpenedEventDto.sessionId),
      )
    logger.info("Saving PageOpenedEvent event: {}", entity)
    return pageOpenedEventRepository.save(entity).awaitSingle()
  }

  suspend fun findAllSessionsInGivenTime(from: Instant, to: Instant): List<UserSession> {
    return listOf(
      UserSession(
        "1", EnvironmentDto.GITHUB_PAGES, listOf(
          VisitedPage(PageNameDto.HOME, Instant.parse("2024-10-10T10:10:00.0Z")),
          VisitedPage(PageNameDto.RESEARCH, Instant.parse("2024-10-10T10:10:10.0Z")),
          VisitedPage(PageNameDto.HOME, Instant.parse("2024-10-10T10:11:00.0Z")),
        )
      ),
      UserSession(
        "2", EnvironmentDto.GITHUB_PAGES, listOf(
          VisitedPage(PageNameDto.HOME, Instant.parse("2024-10-12T10:13:00.0Z")),
          VisitedPage(PageNameDto.CONTACT, Instant.parse("2024-10-12T14:11:00.0Z")),
        )
      )
    )
  }

  companion object {
    val logger: Logger = LoggerFactory.getLogger(AnalyticsService::class.java)
  }
}

class SessionNotFoundException(message: String) : RuntimeException(message)
