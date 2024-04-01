package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import fixture.RedisFixture
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.AnalyticsService
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppOpenedEventId
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.Environment
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.SessionId
import java.time.Instant
import java.util.*
import kotlinx.coroutines.runBlocking
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.mockito.kotlin.any
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.SpringBootTest.UseMainMethod
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.reactive.server.WebTestClient

@SpringBootTest(useMainMethod = UseMainMethod.ALWAYS)
@AutoConfigureWebTestClient
@ActiveProfiles("test")
class LimitingFilterIntegrationTest : RedisFixture() {

  @MockBean lateinit var analyticsService: AnalyticsService

  @Autowired lateinit var webTestClient: WebTestClient

  @Test
  fun whenCalledTooManyTimes_thenShouldRejectNextRequest() {
    `when`(runBlocking { analyticsService.persistAppOpenedEvent(any(), any()) })
        .thenReturn(
            AppOpenedEvent(
                id = AppOpenedEventId.create(),
                insertedAt = Instant.now(),
                eventTime = Instant.now(),
                userAgent = null,
                sessionId = SessionId(UUID.randomUUID()),
                environment = Environment.PWR_SERVER))

    repeat(6) { requestNumber ->
      webTestClient
          .post()
          .uri("/api/v1/analytics/appOpened")
          .contentType(MediaType.APPLICATION_JSON)
          .bodyValue(
              """
          {
            "eventTime": "2020-10-10T10:10:10Z",
            "sessionId": "d7e9a4ae-3582-4b6c-8e6c-dadc38585ecc",
            "environment": "github_pages"
          }
        """)
          .header("x-forwarded-for", "200.200.200.200")
          .exchange()
          .expectStatus()
          .value { status ->
            if (requestNumber < 5) {
              assertThat(status).isEqualTo(201)
            } else {
              assertThat(status).isEqualTo(429)
            }
          }
    }
  }
}
