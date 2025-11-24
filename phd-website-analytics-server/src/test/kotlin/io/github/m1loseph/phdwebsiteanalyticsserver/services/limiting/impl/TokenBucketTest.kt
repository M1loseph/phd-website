package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.time.Clock
import java.time.Duration
import java.time.Instant
import java.time.ZoneId

class TokenBucketTest {
  @Test
  fun `given new bucket when called once then remaining time should be equal to refill duration`() {
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
