package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import fixture.RedisFixture
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.AppOpenedEventRepository
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.PageOpenedEventRepository
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageName
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageOpenedEventId
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.SessionId
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.mockito.kotlin.any
import org.mockito.kotlin.verify
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.SpringBootTest.UseMainMethod
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.reactive.server.WebTestClient
import reactor.core.publisher.Mono
import java.time.Instant
import java.util.UUID

@SpringBootTest(useMainMethod = UseMainMethod.ALWAYS)
@ActiveProfiles("test")
@AutoConfigureWebTestClient
class AnalyticsControllerIntegrationTest : RedisFixture() {
  @MockBean lateinit var appOpenedEventRepository: AppOpenedEventRepository

  @MockBean lateinit var pageOpenedEventRepository: PageOpenedEventRepository

  @Autowired lateinit var webTestClient: WebTestClient

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
  fun whenEventSaved_thenShouldReturnCreatedStatus() {
    `when`(pageOpenedEventRepository.save(any()))
      .thenReturn(
        Mono.just(
          PageOpenedEvent(
            id = PageOpenedEventId.create(),
            eventTime = Instant.now(),
            pageName = PageName.RESEARCH,
            insertedAt = Instant.now(),
            sessionId = SessionId(UUID.fromString("d7e9a4ae-3582-4b6c-8e6c-dadc38585ecc")),
          ),
        ),
      )

    webTestClient
      .post()
      .uri("/api/v1/analytics/pageOpened")
      .contentType(MediaType.APPLICATION_JSON)
      .bodyValue(
        """
                {
                    "pageName": "research",
                    "eventTime": "2023-10-10T10:10:10Z",
                    "sessionId": "d7e9a4ae-3582-4b6c-8e6c-dadc38585ecc"
                }
                """,
      )
      .header("x-forwarded-for", "200.200.200.200")
      .exchange()
      .expectStatus()
      .isEqualTo(201)

    verify(pageOpenedEventRepository).save(any())
  }
}
