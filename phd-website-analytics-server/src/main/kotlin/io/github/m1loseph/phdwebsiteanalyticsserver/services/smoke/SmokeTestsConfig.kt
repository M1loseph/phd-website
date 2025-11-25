package io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke

import com.mongodb.ConnectionString
import com.mongodb.MongoClientSettings
import com.mongodb.reactivestreams.client.MongoClient
import com.mongodb.reactivestreams.client.MongoClients
import io.github.m1loseph.phdwebsiteanalyticsserver.global.mongo.MongoCommandConnectionNameTagsProvider
import io.github.m1loseph.phdwebsiteanalyticsserver.global.mongo.MongoConnectionPoolConnectionNameTagsProvider
import io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke.uri.UriBuilder
import io.micrometer.core.instrument.MeterRegistry
import io.micrometer.core.instrument.binder.mongodb.MongoMetricsCommandListener
import io.micrometer.core.instrument.binder.mongodb.MongoMetricsConnectionPoolListener
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import redis.clients.jedis.JedisPool
import java.net.URI

@Configuration
class SmokeTestsConfig(
  private val meterRegistry: MeterRegistry,
) {
  @Value($$"${spring.mongodb.uri}")
  lateinit var connectionString: String

  @Bean
  fun smokeTestsService(jedisPool: JedisPool): SmokeTestsService {
    val uri =
      UriBuilder
        .fromURI(URI(connectionString))
        .withQueryParameter("serverSelectionTimeoutMS", "1000")
        .withQueryParameter("connectTimeoutMS", "1000")
        .withQueryParameter("socketTimeoutMS", "1000")
        .build()
    val connectionString = ConnectionString(uri.toASCIIString())
    val mongodbClient = mongoClient(connectionString)
    val dataBaseName = connectionString.database!!
    return SmokeTestsService(jedisPool, mongodbClient, dataBaseName)
  }

  // TODO: it breaks the tests
  // @Bean(name = ["smokeTestsMongoClient"], destroyMethod = "close")
  fun mongoClient(connectionString: ConnectionString): MongoClient {
    val customTagsForConnectionPool =
      MongoConnectionPoolConnectionNameTagsProvider(TEST_CONNECTION_NAME)
    val customTagsForCommands = MongoCommandConnectionNameTagsProvider(TEST_CONNECTION_NAME)

    return MongoClients.create(
      MongoClientSettings
        .builder()
        .applyConnectionString(connectionString)
        .addCommandListener(MongoMetricsCommandListener(meterRegistry, customTagsForCommands))
        .applyToConnectionPoolSettings {
          it.addConnectionPoolListener(
            MongoMetricsConnectionPoolListener(meterRegistry, customTagsForConnectionPool),
          )
        }.build(),
    )
  }

  companion object {
    const val TEST_CONNECTION_NAME = "testConnection"
  }
}
