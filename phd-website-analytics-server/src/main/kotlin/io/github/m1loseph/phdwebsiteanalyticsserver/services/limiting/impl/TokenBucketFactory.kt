package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.config.BucketConfiguration
import java.time.Clock

class TokenBucketFactory(
  private val clock: Clock,
) {
  fun createTokenBucket(bucketConfiguration: BucketConfiguration): TokenBucket =
    TokenBucket(
      limit = bucketConfiguration.capacity,
      refillTime = bucketConfiguration.refillInterval,
      refillAmount = bucketConfiguration.refillAmount,
      lastRefill = clock.instant(),
      currentValue = bucketConfiguration.capacity,
      clock = clock,
    )

  fun createTokenBucketFromSnapshot(tokenBucketState: TokenBucketSnapshot): TokenBucket =
    TokenBucket(
      limit = tokenBucketState.limit,
      refillTime = tokenBucketState.refillTime,
      refillAmount = tokenBucketState.refillAmount,
      lastRefill = tokenBucketState.lastRefill,
      currentValue = tokenBucketState.currentValue,
      clock = clock,
    )
}
