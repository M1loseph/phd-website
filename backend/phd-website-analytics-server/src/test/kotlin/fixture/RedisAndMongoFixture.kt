package fixture

import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.testcontainers.containers.GenericContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import org.testcontainers.utility.DockerImageName

@Testcontainers
abstract class RedisAndMongoFixture {
  companion object {
    private const val REDIS_PORT = 6379
    private const val MONGODB_PORT = 27017

    @JvmStatic
    @Container
    val redis: GenericContainer<*> =
      GenericContainer(DockerImageName.parse("redis:7.2.4")).withExposedPorts(REDIS_PORT)

    @JvmStatic
    @Container
    val mongodb: GenericContainer<*> =
      GenericContainer(DockerImageName.parse("mongo:7.0.5")).withExposedPorts(MONGODB_PORT)
        .withEnv("MONGO_INITDB_ROOT_USERNAME", "test")
        .withEnv("MONGO_INITDB_ROOT_PASSWORD", "test")
        .withEnv("MONGO_INITDB_DATABASE", "analytics-server-db")

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
