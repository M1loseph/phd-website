package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting

import io.github.bucket4j.Bucket
import io.github.bucket4j.BucketConfiguration
import io.github.bucket4j.distributed.proxy.ProxyManager
import org.springframework.stereotype.Service
import java.time.Duration

@Service
class LimitingService(
    private val limitingConfiguration: LimitingConfiguration,
    private val proxyManager: ProxyManager<String>,
) {
  fun incrementUsageForIpAddress(ipAddress: IpAddress): RateLimitingResult {
    return findOrCreateBucket(ipAddress.rawIpAddress, limitingConfiguration.singleIp)
  }

  fun incrementGlobalUsage(): RateLimitingResult {
    return findOrCreateBucket(GLOBAL_KEY, limitingConfiguration.global)
  }

  private fun findOrCreateBucket(key: String, bucketConfig: io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.BucketConfiguration): RateLimitingResult {
    val bucket = proxyManager.builder().build(key) {
      BucketConfiguration.builder()
          .addLimit {
            it.capacity(bucketConfig.capacity)
                .refillIntervally(bucketConfig.refillAmount, bucketConfig.refillInterval)
          }
          .build()
    }
    val probe = bucket.tryConsumeAndReturnRemaining(1)
    return if (probe.isConsumed) {
      RateLimitingResult(true, Duration.ZERO)
    } else {
      RateLimitingResult(false, Duration.ofNanos(probe.nanosToWaitForRefill))
    }
  }

  companion object {
    private const val GLOBAL_KEY = "global";
  }
}

data class RateLimitingResult(
    val success: Boolean,
    val timeToNextPossibleCall: Duration
)