package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import fixture.RedisFixture
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.AppOpenedEventRepository
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.PageOpenedEventRepository
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.*
import java.time.Instant
import java.util.*
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.mockito.kotlin.any
import org.mockito.kotlin.verify
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.SpringBootTest.UseMainMethod
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post

@SpringBootTest(useMainMethod = UseMainMethod.ALWAYS)
@ActiveProfiles("test")
@AutoConfigureMockMvc
class AnalyticsControllerIntegrationTest : RedisFixture() {

  @MockBean lateinit var appOpenedEventRepository: AppOpenedEventRepository

  @MockBean lateinit var pageOpenedEventRepository: PageOpenedEventRepository

  @Autowired lateinit var mockMvc: MockMvc

  @Test
  fun whenSendIncorrectPageName_thenShouldReturnBadRequestStatus() {
    mockMvc
        .perform(
            post("/api/v1/analytics/pageOpened")
                .content(
                    """
                {
                    "pageName": "test",
                    "eventTime": "2023-10-10T10:10:10Z",
                    "sessionId": "d7e9a4ae-3582-4b6c-8e6c-dadc38585ecc"
                }
                """)
                .contentType(MediaType.APPLICATION_JSON)
                .header("x-forwarded-for", "200.200.200.200"))
        .andExpect { assertThat(it.response.status).isEqualTo(400) }
  }

  @Test
  fun whenEventSaved_thenShouldReturnCreatedStatus() {
    `when`(pageOpenedEventRepository.save(any()))
        .thenReturn(
            PageOpenedEvent(
                id = PageOpenedEventId.create(),
                eventTime = Instant.now(),
                pageName = PageName.RESEARCH,
                insertedAt = Instant.now(),
                sessionId = SessionId(UUID.fromString("d7e9a4ae-3582-4b6c-8e6c-dadc38585ecc")),
            ),
        )

    mockMvc
        .perform(
            post("/api/v1/analytics/pageOpened")
                .content(
                    """
                {
                    "pageName": "research",
                    "eventTime": "2023-10-10T10:10:10Z",
                    "sessionId": "d7e9a4ae-3582-4b6c-8e6c-dadc38585ecc"
                }
                """)
                .contentType(MediaType.APPLICATION_JSON)
                .header("x-forwarded-for", "200.200.200.200"))
        .andExpect { assertThat(it.response.status).isEqualTo(201) }

    verify(pageOpenedEventRepository).save(any())
  }
}
