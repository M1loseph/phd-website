package fixture

import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.testcontainers.containers.GenericContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import org.testcontainers.utility.DockerImageName

@Testcontainers
abstract class RedisFixture {
  companion object {
    private const val REDIS_PORT = 6379

    @JvmStatic
    @Container
    val redis: GenericContainer<*> =
        GenericContainer(DockerImageName.parse("redis:7.2.4")).withExposedPorts(REDIS_PORT)

    @JvmStatic
    @DynamicPropertySource
    fun registerRedisProperties(registry: DynamicPropertyRegistry) {
      registry.add("web.limiting.redisUrl") {
        "redis://${redis.host}:${redis.getMappedPort(REDIS_PORT)}"
      }
    }
  }
}
