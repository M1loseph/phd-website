package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

import java.time.Instant
import org.bson.types.ObjectId
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document

@JvmInline
value class AppOpenedEventId(private val id: ObjectId) {
  companion object {
    fun create() = AppOpenedEventId(ObjectId())
  }
}

@Document
data class AppOpenedEvent(
    @Id val id: AppOpenedEventId = AppOpenedEventId.create(),
    val eventTime: Instant,
    val insertedAt: Instant,
    val userAgent: UserAgentName?,
    val sessionId: SessionId,
)
