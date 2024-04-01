package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

import fixture.HashMapTokenBucketRepository
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.config.BucketConfiguration
import java.time.Clock
import java.time.Duration
import java.time.Instant
import java.time.ZoneId
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runTest
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

class LimitingServiceTest {
  private lateinit var limitingService: LimitingService
  private lateinit var repository: TokenBucketRepository

  @BeforeEach
  fun init() {
    repository = HashMapTokenBucketRepository()
    limitingService =
        LimitingService(
            BucketConfiguration(1, 2, Duration.ofSeconds(1)),
            BucketConfiguration(2000, 2, Duration.ofSeconds(1)),
            TokenBucketFactory(Clock.fixed(Instant.now(), ZoneId.systemDefault())),
            repository,
            ::hashCodeHash,
        )
  }

  @Test
  @OptIn(ExperimentalCoroutinesApi::class)
  fun whenCalledFromMultipleThreads_thenShouldCountCorrectly() = runTest {
    repeat(1000) { launch { limitingService.incrementGlobalUsage() } }
    advanceUntilIdle()

    assertThat(repository.findById(GlobalBucketId)!!.currentValue).isEqualTo(1000)
  }
}
