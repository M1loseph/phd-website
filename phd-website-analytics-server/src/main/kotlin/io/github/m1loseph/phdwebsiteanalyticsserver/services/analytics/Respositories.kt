package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.AppOpenedEvent
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.PageOpenedEvent
import org.bson.types.ObjectId
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository

@Repository interface AppOpenedEventRepository : MongoRepository<AppOpenedEvent, ObjectId>

@Repository interface PageOpenedEventRepository : MongoRepository<PageOpenedEvent, ObjectId>
