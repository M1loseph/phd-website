package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.config

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.LimitingService
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.TokenBucketFactory
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.TokenBucketRepository
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.hashCodeHash
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization.BucketSnapshotSerializer
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization.JvmCompressingBucketSnapshotSerializer
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization.MultipleVersionsAwareSerializer
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization.VersionedBucketSnapshotSerializer
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization.VersionedBucketSnapshotSerializer.Companion.JVM_COMPRESSING_BUCKET_SNAPSHOT_SERIALIZER
import jakarta.validation.Valid
import jakarta.validation.constraints.Min
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.validation.annotation.Validated
import redis.clients.jedis.JedisPool
import java.net.URI
import java.time.Clock
import java.time.Duration

@Configuration
@EnableConfigurationProperties(LimitingConfiguration::class)
class LimitingBeanFactory(private val limitingConfiguration: LimitingConfiguration) {
  @Bean(destroyMethod = "close")
  fun jedisPool(): JedisPool = JedisPool(limitingConfiguration.redisUrl)

  @Bean fun leakyBucketFactory(): TokenBucketFactory = TokenBucketFactory(Clock.systemUTC())

  @Bean
  fun limitingService(
    tokenBucketFactory: TokenBucketFactory,
    tokenBucketRepository: TokenBucketRepository,
  ): LimitingService =
    LimitingService(
      singleIpConfig = limitingConfiguration.singleIp,
      globalConfig = limitingConfiguration.global,
      tokenBucketFactory = tokenBucketFactory,
      tokenBucketRepository = tokenBucketRepository,
      hashFunction = ::hashCodeHash,
    )

  @Bean
  fun bucketSnapshotSerializer(): BucketSnapshotSerializer {
    val jvmSerializer =
      VersionedBucketSnapshotSerializer(
        JVM_COMPRESSING_BUCKET_SNAPSHOT_SERIALIZER,
        JvmCompressingBucketSnapshotSerializer(),
      )
    return MultipleVersionsAwareSerializer(
      jvmSerializer,
      mapOf(JVM_COMPRESSING_BUCKET_SNAPSHOT_SERIALIZER to jvmSerializer),
    )
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
