package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

import java.time.Clock
import java.time.Duration
import java.time.Instant
import kotlin.math.ceil

class TokenBucket
internal constructor(
    val limit: Long,
    val refillTime: Duration,
    val refillAmount: Long,
    var lastRefill: Instant,
    var currentValue: Long,
    val clock: Clock,
) {

  fun takeOneToken(): TokenAcquireResult {
    refill()
    if (currentValue == 0L) {
      return TokenDeniedResult(
          remainingTime = Duration.between(lastRefill + refillTime, clock.instant()))
    }
    currentValue -= 1
    return TokenAcquiredResult
  }

  fun createSnapshot(): TokenBucketSnapshot {
    return TokenBucketSnapshot(limit, refillTime, refillAmount, lastRefill, currentValue)
  }

  fun timeToFull(): Duration {
    val diff = limit - currentValue
    val ticks = ceil(diff.toDouble() / refillAmount).toLong()
    return refillTime.multipliedBy(ticks)
  }

  private fun refill() {
    if (lastRefill + refillTime > clock.instant()) {
      return
    }
    currentValue = (currentValue + refillAmount).coerceAtMost(limit)
  }
}

sealed class TokenAcquireResult

data object TokenAcquiredResult : TokenAcquireResult()

data class TokenDeniedResult(val remainingTime: Duration) : TokenAcquireResult()
