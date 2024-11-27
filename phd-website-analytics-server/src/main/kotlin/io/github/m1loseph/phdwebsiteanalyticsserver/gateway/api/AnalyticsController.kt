package io.github.m1loseph.phdwebsiteanalyticsserver.gateway.api

import io.github.m1loseph.phdwebsiteanalyticsserver.gateway.config.Whitelist
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.AnalyticsService
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.SessionNotFoundException
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.AppOpenedEventResponse
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.CreateAppOpenedEventDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.CreatePageOpenedEventDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.UserSession
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.InvalidVersionException
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.UserAgentName
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken
import org.springframework.security.oauth2.core.user.OAuth2User
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.HttpStatusCodeException
import org.springframework.web.server.ResponseStatusException
import java.time.Instant

// TODO: introduce some error class?
@RestController
@RequestMapping("/api/v1/analytics")
class AnalyticsController(private val analyticsService: AnalyticsService, private val whitelist: Whitelist) {
  @PostMapping("/appOpened")
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun onAppOpenedEvent(
    @RequestHeader("User-Agent") userAgent: String?,
    @RequestBody @Valid createAppOpenedEvent: CreateAppOpenedEventDto,
  ): AppOpenedEventResponse {
    val sessionId =
      analyticsService.persistAppOpenedEvent(
        createAppOpenedEvent,
        UserAgentName.fromNullable(userAgent),
      )
    return AppOpenedEventResponse(sessionId.rawValue.toString())
  }

  @PostMapping("/pageOpened")
  @ResponseStatus(HttpStatus.CREATED)
  suspend fun onPageOpenedEvent(
    @RequestHeader("User-Agent") userAgent: String?,
    @RequestBody @Valid createPageOpenedEventDto: CreatePageOpenedEventDto,
  ) {
    analyticsService.persistPageOpenedEvent(
      createPageOpenedEventDto,
      UserAgentName.fromNullable(userAgent),
    )
  }

  @GetMapping
  suspend fun findPageOpenEventsInTimeRage(
    authentication: OAuth2AuthenticationToken,
    @RequestParam from: Instant?,
    @RequestParam to: Instant?,
  ): List<UserSession> {
    // TODO: add some reasonable error page
    // TODO: also add reasonable error page to NGINx
    val user = authentication.principal
    val login = user.attributes["login"]
    if (!whitelist.users.contains(login)) {
      throw ResponseStatusException(HttpStatus.FORBIDDEN)
    }
    return analyticsService.findAllSessionsInGivenTime(from ?: Instant.now(), to ?: Instant.now())
  }

  @ExceptionHandler(SessionNotFoundException::class)
  fun handleSessionNotFoundException(): ResponseEntity<Void> {
    return ResponseEntity.badRequest().build()
  }

  @ExceptionHandler(InvalidVersionException::class)
  fun handleInvalidVersionFormatException(): ResponseEntity<Void> {
    return ResponseEntity.badRequest().build()
  }
}
