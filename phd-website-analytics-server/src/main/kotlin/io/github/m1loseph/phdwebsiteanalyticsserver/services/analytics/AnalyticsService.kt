package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.CreateAppOpenedEventDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.CreatePageOpenedEventDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.PageNameDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.*
import java.time.Clock
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

@Service
class AnalyticsService(
    private val appOpenedEventRepository: AppOpenedEventRepository,
    private val pageOpenedEventRepository: PageOpenedEventRepository,
    private val serverClock: Clock
) {

  fun persistAppOpenedEvent(
      createAppOpenedEventDto: CreateAppOpenedEventDto,
      userAgent: UserAgentName?
  ): AppOpenedEvent {
    val entity =
        AppOpenedEvent(
            eventTime = createAppOpenedEventDto.eventTime,
            insertedAt = serverClock.instant(),
            userAgent = userAgent,
            sessionId = SessionId(createAppOpenedEventDto.sessionId))
    logger.info("Saving event: {}", entity)
    return appOpenedEventRepository.save(entity)
  }

  fun persistPageOpenedEvent(
      createPageOpenedEventDto: CreatePageOpenedEventDto,
      userAgent: UserAgentName?
  ): PageOpenedEvent {
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
            userAgent = userAgent,
            sessionId = SessionId(createPageOpenedEventDto.sessionId))
    logger.info("Saving event: {}", entity)
    return pageOpenedEventRepository.save(entity)
  }

  companion object {
    val logger: Logger = LoggerFactory.getLogger(AnalyticsService::class.java)
  }
}
