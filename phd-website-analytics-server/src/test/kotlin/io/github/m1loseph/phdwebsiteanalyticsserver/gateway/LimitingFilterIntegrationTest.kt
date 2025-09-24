package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import fixture.RedisAndMongoFixture
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.SpringBootTest.UseMainMethod
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.reactive.server.WebTestClient
import org.testcontainers.junit.jupiter.Testcontainers

@Testcontainers
@SpringBootTest(useMainMethod = UseMainMethod.ALWAYS)
@AutoConfigureWebTestClient
@ActiveProfiles("limiting-filter-test")
class LimitingFilterIntegrationTest : RedisAndMongoFixture() {
  @Autowired
  lateinit var webTestClient: WebTestClient

  @Test
  fun whenCalledTooManyTimes_thenShouldRejectNextRequest() {
    repeat(6) { requestNumber ->
      webTestClient
        .post()
        .uri("/api/v1/analytics/appOpened")
        .contentType(MediaType.APPLICATION_JSON)
        .bodyValue(
          """
          {
            "eventTime": "2020-10-10T10:10:10Z",
            "environment": "github_pages",
            "appVersion": "1.0"
          }
        """,
        ).header("x-forwarded-for", "200.200.200.200")
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
