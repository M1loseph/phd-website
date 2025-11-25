package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.SessionId
import org.bson.types.ObjectId
import org.springframework.data.mongodb.repository.Query
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import org.springframework.stereotype.Repository
import java.time.Instant

@Repository
interface AppOpenedEventRepository : ReactiveCrudRepository<AppOpenedEvent, ObjectId> {
  suspend fun existsBySessionId(sessionId: SessionId): Boolean

  @Query($$"{ 'insertedAt': { $gte: ?0, $lte: ?1 } }")
  suspend fun findByInsertedAtBetween(
    from: Instant,
    to: Instant,
  ): List<AppOpenedEvent>
}

@Repository
interface PageOpenedEventRepository : ReactiveCrudRepository<PageOpenedEvent, ObjectId> {
  @Query($$"{ 'sessionId': { $in: ?0 } }")
  suspend fun findBySessionIdIn(sessionIds: List<SessionId>): List<PageOpenedEvent>
}
