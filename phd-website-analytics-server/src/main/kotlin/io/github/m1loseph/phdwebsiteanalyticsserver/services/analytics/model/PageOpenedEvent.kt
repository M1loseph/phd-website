package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

import java.time.Instant
import org.bson.types.ObjectId
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document

enum class PageName {
  HOME,
  CONTACT,
  CONSULTATION,
  RESEARCH,
  TEACHING
}

@Document
data class PageOpenedEvent(
    @Id val id: PageOpenedEventId = PageOpenedEventId.create(),
    val eventTime: Instant,
    val pageName: PageName,
    val insertedAt: Instant,
    val userAgent: UserAgentName?,
    val sessionId: SessionId,
)

@JvmInline
value class PageOpenedEventId(private val id: ObjectId) {
  companion object {
    fun create(): PageOpenedEventId {
      return PageOpenedEventId(ObjectId())
    }
  }
}
