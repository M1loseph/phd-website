package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import fixture.RedisAndMongoFixture
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.AppOpenedEventRepository
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.dto.AppOpenedEventResponse
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.SessionId
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.SpringBootTest.UseMainMethod
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.reactive.server.WebTestClient
import org.springframework.test.web.reactive.server.expectBody
import java.util.UUID

@SpringBootTest(useMainMethod = UseMainMethod.ALWAYS)
@ActiveProfiles("test")
@AutoConfigureWebTestClient
class AnalyticsControllerIntegrationTest : RedisAndMongoFixture() {

  @Autowired
  lateinit var webTestClient: WebTestClient

  @Autowired
  lateinit var appOpenedEventRepository: AppOpenedEventRepository

  @Test
  fun whenSendIncorrectPageName_thenShouldReturnBadRequestStatus() {
    webTestClient
      .post()
      .uri("/api/v1/analytics/pageOpened")
      .contentType(MediaType.APPLICATION_JSON)
      .bodyValue(
        """
                {
                    "pageName": "test",
                    "eventTime": "2023-10-10T10:10:10Z",
                    "sessionId": "d7e9a4ae-3582-4b6c-8e6c-dadc38585ecc"
                }
                """,
      )
      .header("x-forwarded-for", "200.200.200.200")
      .exchange()
      .expectStatus()
      .isEqualTo(400)
  }

  @Test
  fun shouldEstablishSession() {
    val appOpenedEventResponse =
      webTestClient
        .post()
        .uri("/api/v1/analytics/appOpened")
        .contentType(MediaType.APPLICATION_JSON)
        .bodyValue(
          """
                {
                    "eventTime": "2023-10-10T10:10:10Z",
                    "environment": "pwr_server"
                }
                """,
        )
        .header("x-forwarded-for", "200.200.200.200")
        .exchange()
        .expectStatus()
        .isEqualTo(201)
        .expectBody<AppOpenedEventResponse>()
        .returnResult()

    val rawSessionId = appOpenedEventResponse.responseBody!!.sessionId
    val sessionId = SessionId(UUID.fromString(rawSessionId))
    assertThat(appOpenedEventRepository.existsBySessionId(sessionId).block()).isTrue()

    webTestClient
      .post()
      .uri("/api/v1/analytics/pageOpened")
      .contentType(MediaType.APPLICATION_JSON)
      .bodyValue(
        """
                {
                    "eventTime": "2023-10-10T10:10:13Z",
                    "pageName": "home",
                    "sessionId": "$rawSessionId"
                }
                """,
      )
      .header("x-forwarded-for", "200.200.200.200")
      .exchange()
      .expectStatus()
      .isEqualTo(201)
  }

  @Test
  fun whenSendPageOpenedEventWithoutEstablishingSession_thenShouldReturnBadRequest() {
    webTestClient
      .post()
      .uri("/api/v1/analytics/pageOpened")
      .contentType(MediaType.APPLICATION_JSON)
      .bodyValue(
        """
                {
                    "eventTime": "2023-10-10T10:10:13Z",
                    "pageName": "home",
                    "sessionId": "0b6cb58b-7074-4025-9eeb-24c67c441d2f"
                }
                """,
      )
      .header("x-forwarded-for", "200.200.200.200")
      .exchange()
      .expectStatus()
      .isEqualTo(400)
  }
}
