package io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke

import com.mongodb.MongoException
import org.bson.BsonDocument
import org.bson.BsonInt64
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.data.mongodb.core.MongoTemplate
import org.springframework.stereotype.Service
import redis.clients.jedis.JedisPool
import redis.clients.jedis.exceptions.JedisConnectionException

enum class SmokeTestResult {
  OK,
  ERROR
}

@Service
class SmokeTestsService(
    private val jedisPool: JedisPool,
    private val mongodbTemplate: MongoTemplate,
) {
  fun testIfConnectionToRedisIsAlive(): SmokeTestResult {
    return try {
      jedisPool.resource.use {
        it.ping()
        SmokeTestResult.OK
      }
    } catch (e: JedisConnectionException) {
      logger.error("Error when executing ping in smoke test", e)
      SmokeTestResult.ERROR
    }
  }

  // TODO: maybe set a timeout in the future
  fun testIfConnectionToMongodbIsAlive(): SmokeTestResult {
    return try {
      val db = mongodbTemplate.db
      val command = BsonDocument("ping", BsonInt64(1))
      db.runCommand(command)
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
