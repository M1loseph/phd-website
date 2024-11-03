package fixture

import org.junit.jupiter.api.AfterAll
import org.junit.jupiter.api.BeforeAll
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.testcontainers.containers.GenericContainer
import org.testcontainers.utility.DockerImageName

abstract class RedisAndMongoFixture {
  companion object {
    private const val REDIS_PORT = 6379
    private const val MONGODB_PORT = 27017

    @JvmStatic
    val redis: GenericContainer<*> =
      GenericContainer(DockerImageName.parse("redis:7.2.4"))
        .withExposedPorts(REDIS_PORT)

    @JvmStatic
    val mongodb: GenericContainer<*> =
      GenericContainer(DockerImageName.parse("mongo:7.0.5"))
        .withExposedPorts(MONGODB_PORT)
        .withEnv("MONGO_INITDB_ROOT_USERNAME", "test")
        .withEnv("MONGO_INITDB_ROOT_PASSWORD", "test")
        .withEnv("MONGO_INITDB_DATABASE", "analytics-server-db")

    init {
      redis.start()
      mongodb.start()
    }

    @BeforeAll
    @JvmStatic
    fun cleanup() {
      mongodb.execInContainer(
        "mongosh",
        "mongodb://test:test@localhost:27017/analytics-server-db?authSource=admin",
        "--eval",
        "db.dropDatabase()"
      )
      redis.execInContainer("redis-cli", "flushall")
    }


    @JvmStatic
    @DynamicPropertySource
    fun registerRedisProperties(registry: DynamicPropertyRegistry) {
      registry.add("web.limiting.redisUrl") {
        "redis://${redis.host}:${redis.getMappedPort(REDIS_PORT)}"
      }
      registry.add("spring.data.mongodb.uri") {
        "mongodb://test:test@${mongodb.host}:${mongodb.getMappedPort(MONGODB_PORT)}/analytics-server-db?authSource=admin"
      }
    }
  }
}
