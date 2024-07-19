package io.github.m1loseph.phdwebsiteanalyticsserver.global

import io.github.m1loseph.phdwebsiteanalyticsserver.global.mongo.MongoCommandConnectionNameTagsProvider
import io.github.m1loseph.phdwebsiteanalyticsserver.global.mongo.MongoConnectionPoolConnectionNameTagsProvider
import io.micrometer.core.instrument.binder.mongodb.MongoCommandTagsProvider
import io.micrometer.core.instrument.binder.mongodb.MongoConnectionPoolTagsProvider
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class GlobalConfiguration {
  @Bean
  fun mongoConnectionPoolTagsProvider(): MongoConnectionPoolTagsProvider =
    MongoConnectionPoolConnectionNameTagsProvider(GLOBAL_MONGO_CLIENT_NAME)

  @Bean
  fun mongoCommandTagsProvider(): MongoCommandTagsProvider = MongoCommandConnectionNameTagsProvider(GLOBAL_MONGO_CLIENT_NAME)

  companion object {
    const val GLOBAL_MONGO_CLIENT_NAME = "global"
  }
}
