package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.time.Clock
import java.time.Duration
import java.time.Instant
import java.time.ZoneId

class TokenBucketTest {
  @Test
  fun givenNewBucket_whenCalledOnce_thenRemainingTimeShouldBeEqualToRefillDuration() {
    val fixedClock = Clock.fixed(Instant.now(), ZoneId.systemDefault())
    val tokenBucket =
      TokenBucket(
        limit = 100,
        refillTime = Duration.ofSeconds(100),
        refillAmount = 10,
        lastRefill = fixedClock.instant(),
        currentValue = 100,
        clock = fixedClock,
      )

    tokenBucket.takeOneToken()

    assertThat(tokenBucket.timeToFull()).isEqualTo(Duration.ofSeconds(100))
  }
}
