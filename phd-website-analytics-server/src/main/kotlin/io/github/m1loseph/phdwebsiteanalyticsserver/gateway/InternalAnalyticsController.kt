package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.gateway.dto.AppVersionDto
import io.github.m1loseph.phdwebsiteanalyticsserver.gateway.dto.PageOpenedEventDto
import io.github.m1loseph.phdwebsiteanalyticsserver.gateway.dto.SessionDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.AnalyticsService
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.EnvironmentDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.PageNameDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.SessionIdDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.Environment
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.Instant

// TODO: move this endpoint to AnalyticsController after testing and add authentication
@RestController
@RequestMapping("/internal/api/v1/analytics")
class InternalAnalyticsController(
  private val analyticsService: AnalyticsService,
) {
  @GetMapping
  suspend fun findSessionsBetweenDates(
    @RequestParam(required = true) from: Instant,
    @RequestParam(required = true) to: Instant,
  ): List<SessionDto> {
    val sessions = analyticsService.findSessionsBetweenDates(from, to)
    return sessions.map {
      SessionDto(
        sessionId = SessionIdDto.fromModel(it.appOpenedEvent.sessionId),
        appVersion = it.appOpenedEvent.appVersion.let { version ->
          AppVersionDto(
            major =  version.major,
            minor = version.minor,
            snapshot = version.commitsAheadOfTag != null,
          )
        },
        environment = when(it.appOpenedEvent.environment) {
          Environment.PWR_SERVER -> EnvironmentDto.PWR_SERVER
          Environment.GITHUB_PAGES -> EnvironmentDto.GITHUB_PAGES
        },
        pageOpenings =
          it.pageOpenedEvents.map { pageOpenedEvent ->
            PageOpenedEventDto(
              pageName = PageNameDto.fromModel(pageOpenedEvent.pageName),
              userTime = pageOpenedEvent.eventTime,
              serverTime = pageOpenedEvent.insertedAt,
            )
          },
      )
    }
  }
}
