package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageOpenedEvent
import org.bson.types.ObjectId
import org.springframework.data.repository.reactive.ReactiveCrudRepository
import org.springframework.stereotype.Repository

@Repository interface AppOpenedEventRepository : ReactiveCrudRepository<AppOpenedEvent, ObjectId>

@Repository interface PageOpenedEventRepository : ReactiveCrudRepository<PageOpenedEvent, ObjectId>
