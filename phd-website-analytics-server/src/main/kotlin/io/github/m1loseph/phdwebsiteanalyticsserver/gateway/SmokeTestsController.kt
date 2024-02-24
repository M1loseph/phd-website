package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import com.mongodb.MongoException
import org.bson.BsonDocument
import org.bson.BsonInt64
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.data.mongodb.core.MongoTemplate
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import redis.clients.jedis.JedisPool
import redis.clients.jedis.exceptions.JedisConnectionException

@RestController
@RequestMapping("/internal/tests/smoke")
class SmokeTestsController(
    private val jedisPool: JedisPool,
    private val mongodbTemplate: MongoTemplate,
) {

  @GetMapping("/redis")
  fun testIfConnectionToRedisIsAlive(): ResponseEntity<Void> {
    try {
      jedisPool.resource.use {
        it.ping()
        return ResponseEntity(HttpStatus.OK)
      }
    } catch (e: JedisConnectionException) {
      logger.error("Error when executing ping in smoke test", e)
      return ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR)
    }
  }

  // TODO: maybe set a timeout in the future
  @GetMapping("/mongodb")
  fun testIfConnectionToMongodbIsAlive(): ResponseEntity<Void> {
    try {
      val db = mongodbTemplate.db
      val command = BsonDocument("ping", BsonInt64(1))
      db.runCommand(command)
      return ResponseEntity(HttpStatus.OK)
    } catch (e: MongoException) {
      logger.error("Error when executing ping command on mongodb", e)
      return ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR)
    }
  }

  companion object {
    val logger: Logger = LoggerFactory.getLogger(SmokeTestsController::class.java)
  }
}
