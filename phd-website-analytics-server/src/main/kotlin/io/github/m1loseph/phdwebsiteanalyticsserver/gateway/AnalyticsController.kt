package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.AnalyticsService
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.AppOpenedEventResponse
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.CreateAppOpenedEventDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.CreatePageOpenedEventDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.UserAgentName
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/analytics")
class AnalyticsController(
  private val analyticsService: AnalyticsService,
) {
  @PostMapping("/appOpened")
  suspend fun onAppOpenedEvent(
    @RequestHeader("User-Agent") userAgent: String?,
    @RequestBody @Valid createAppOpenedEvent: CreateAppOpenedEventDto,
  ): ResponseEntity<AppOpenedEventResponse> {
    val sessionId =
      analyticsService.persistAppOpenedEvent(
        createAppOpenedEvent,
        UserAgentName.fromNullable(userAgent),
      )
    val response = AppOpenedEventResponse(sessionId.rawValue.toString())
    return ResponseEntity(response, HttpStatus.CREATED)
  }

  @PostMapping("/pageOpened")
  suspend fun onPageOpenedEvent(
    @RequestBody @Valid createPageOpenedEventDto: CreatePageOpenedEventDto,
  ): ResponseEntity<Void> {
    analyticsService.persistPageOpenedEvent(
      createPageOpenedEventDto,
    )
    return ResponseEntity(HttpStatus.CREATED)
  }
}
