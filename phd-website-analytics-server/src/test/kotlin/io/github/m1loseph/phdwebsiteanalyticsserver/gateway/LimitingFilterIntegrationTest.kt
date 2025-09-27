package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import fixture.RedisAndMongoFixture
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.IpAddressBucketId
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.TokenBucketRepository
import org.assertj.core.api.Assertions.assertThat
import org.hamcrest.core.IsEqual
import org.junit.jupiter.api.BeforeEach
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

  @Autowired
  lateinit var tokenBucketRepository: TokenBucketRepository

  @BeforeEach
  fun setup() {
    tokenBucketRepository.clear(IpAddressBucketId(X_FORWARDED_FOR_HEADER_VALUE))
  }

  @Test
  fun whenCalledTooManyTimes_thenShouldRejectNextRequest() {
    repeat(ALLOWED_REQUESTS_WITHOUT_BLOCKING + 1) { requestNumber ->
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
        ).header("x-forwarded-for", X_FORWARDED_FOR_HEADER_VALUE)
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

  @Test
  fun whenCalledTooManyTimes_butReceivedOptionsRequest_thenShouldNotReject() {
    repeat(ALLOWED_REQUESTS_WITHOUT_BLOCKING) { _ ->
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
        ).header("x-forwarded-for", X_FORWARDED_FOR_HEADER_VALUE)
        .exchange()
        .expectStatus()
        .value(IsEqual(201))
    }

    webTestClient
      .options()
      .uri("/api/v1/analytics/appOpened")
      .header("x-forwarded-for", X_FORWARDED_FOR_HEADER_VALUE)
      .exchange()
      .expectStatus()
      .value(IsEqual(200))
  }

  companion object {
    const val ALLOWED_REQUESTS_WITHOUT_BLOCKING = 5
    const val X_FORWARDED_FOR_HEADER_VALUE = "200.200.200.200"
  }
}
