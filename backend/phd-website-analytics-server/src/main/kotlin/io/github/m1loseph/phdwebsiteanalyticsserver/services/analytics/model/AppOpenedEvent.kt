package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

import org.bson.types.ObjectId
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import java.time.Instant

@JvmInline
value class AppOpenedEventId(private val id: ObjectId) {
  companion object {
    fun create() = AppOpenedEventId(ObjectId())
  }
}

enum class Environment {
  PWR_SERVER,
  GITHUB_PAGES,
}

// TODO: add indexing for session id
@Document
data class AppOpenedEvent(
  @Id val id: AppOpenedEventId = AppOpenedEventId.create(),
  val eventTime: Instant,
  val insertedAt: Instant,
  val userAgent: UserAgentName?,
  val sessionId: SessionId,
  val environment: Environment,
)
