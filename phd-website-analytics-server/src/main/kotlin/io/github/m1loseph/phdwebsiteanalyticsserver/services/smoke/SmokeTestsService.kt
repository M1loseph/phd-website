package io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke

import com.mongodb.MongoException
import com.mongodb.reactivestreams.client.MongoClient
import kotlinx.coroutines.reactive.awaitSingle
import org.bson.BsonDocument
import org.bson.BsonInt64
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import redis.clients.jedis.JedisPool
import redis.clients.jedis.exceptions.JedisConnectionException

enum class SmokeTestResult {
  OK,
  ERROR,
}

class SmokeTestsService(
  private val jedisPool: JedisPool,
  private val mongoClient: MongoClient,
  private val databaseName: String,
) {
  fun testIfConnectionToRedisIsAlive(): SmokeTestResult =
    try {
      jedisPool.resource.use {
        it.ping()
        SmokeTestResult.OK
      }
    } catch (e: JedisConnectionException) {
      logger.error("Error when executing ping in smoke test", e)
      SmokeTestResult.ERROR
    }

  suspend fun testIfConnectionToMongodbIsAlive(): SmokeTestResult {
    return try {
      val ping = BsonDocument("ping", BsonInt64(1))
      mongoClient.getDatabase(databaseName).runCommand(ping).awaitSingle()
      SmokeTestResult.OK
    } catch (e: MongoException) {
      logger.error("Error when executing ping command on mongodb", e)
      return SmokeTestResult.ERROR
    }
  }

  companion object {
    val logger: Logger = LoggerFactory.getLogger(SmokeTestsService::class.java)
  }
}
