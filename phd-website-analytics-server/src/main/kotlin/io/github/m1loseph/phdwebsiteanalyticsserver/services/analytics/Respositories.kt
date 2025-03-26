package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.SessionId
import org.bson.types.ObjectId
import org.springframework.data.mongodb.core.ReactiveMongoOperations
import org.springframework.data.mongodb.core.query.Query.query
import org.springframework.data.mongodb.core.query.where
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import org.springframework.stereotype.Component
import org.springframework.stereotype.Repository
import reactor.core.publisher.Mono

interface AppOpenedEventRepositoryCustom {
  fun existsBySessionId(sessionId: SessionId): Mono<Boolean>
}

@Repository
interface AppOpenedEventRepository :
  ReactiveCrudRepository<AppOpenedEvent, ObjectId>,
  AppOpenedEventRepositoryCustom

@Repository
interface PageOpenedEventRepository : ReactiveCrudRepository<PageOpenedEvent, ObjectId>

@Component
class AppOpenedEventRepositoryCustomImpl(
  val mongoOperations: ReactiveMongoOperations,
) : AppOpenedEventRepositoryCustom {
  override fun existsBySessionId(sessionId: SessionId): Mono<Boolean> {
    val searchBySessionIdQuery = query(where(AppOpenedEvent::sessionId).`is`(sessionId.rawValue))

    return mongoOperations
      .count(searchBySessionIdQuery, AppOpenedEvent::class.java)
      .map { it > 0 }
  }
}
