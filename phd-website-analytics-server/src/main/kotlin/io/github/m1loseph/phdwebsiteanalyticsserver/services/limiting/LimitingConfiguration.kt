package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting

import io.github.bucket4j.distributed.ExpirationAfterWriteStrategy
import io.github.bucket4j.distributed.proxy.ProxyManager
import io.github.bucket4j.distributed.serialization.Mapper
import io.github.bucket4j.redis.jedis.cas.JedisBasedProxyManager
import jakarta.validation.Valid
import jakarta.validation.constraints.Min
import java.net.URI
import java.time.Duration
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.validation.annotation.Validated
import redis.clients.jedis.JedisPool

@Configuration
@EnableConfigurationProperties(LimitingConfiguration::class)
class LimitingBeanFactory(private val limitingConfiguration: LimitingConfiguration) {

  @Bean
  fun jedisPool(): JedisPool {
    return JedisPool(limitingConfiguration.redisUrl)
  }

  @Bean
  fun proxyManager(jedisPool: JedisPool): ProxyManager<String> {
    return JedisBasedProxyManager.builderFor(jedisPool)
        .withKeyMapper(Mapper.STRING)
        .withExpirationStrategy(
            ExpirationAfterWriteStrategy.basedOnTimeForRefillingBucketUpToMax(
                limitingConfiguration.fullBucketExpiration))
        .build()
  }
}

@Validated
@ConfigurationProperties("web.limiting")
data class LimitingConfiguration(
    val redisUrl: URI,
    val fullBucketExpiration: Duration,
    @field:Valid val singleIp: BucketConfiguration,
    @field:Valid val global: BucketConfiguration,
)

@Validated
data class BucketConfiguration(
    @field:Min(1) val capacity: Long,
    @field:Min(1) val refillAmount: Long,
    val refillInterval: Duration,
)
