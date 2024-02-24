package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import fixture.RedisFixture
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.Mockito.anyString
import org.mockito.Mockito.`when`
import org.mockito.kotlin.any
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.SpringBootTest.UseMainMethod
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post

@SpringBootTest(useMainMethod = UseMainMethod.ALWAYS)
@AutoConfigureMockMvc
@ActiveProfiles("test")
class LimitingFilterIntegrationTest : RedisFixture() {

  @MockBean lateinit var analyticsController: AnalyticsController

  @Autowired lateinit var mockMvc: MockMvc

  @Test
  fun whenCalledTooManyTimes_thenShouldRejectNextRequest() {
    `when`(analyticsController.onAppOpenedEvent(anyString(), any()))
        .thenReturn(ResponseEntity(HttpStatus.CREATED))

    repeat(6) { requestNumber ->
      mockMvc
          .perform(
              post("/api/v1/analytics/appOpened")
                  .content(
                      """
          {
            "eventTime": "2020-10-10T10:10:10Z",
            "sessionId": "d7e9a4ae-3582-4b6c-8e6c-dadc38585ecc"
          }
        """)
                  .contentType("application/json"))
          .andExpect {
            if (requestNumber < 5) {
              assertThat(it.response.status).isEqualTo(201)
            } else {
              assertThat(it.response.status).isEqualTo(429)
            }
          }
    }
  }
}
