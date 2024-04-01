package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.config.BucketConfiguration
import kotlin.math.absoluteValue
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

class LimitingService(
    private val singleIpConfig: BucketConfiguration,
    private val globalConfig: BucketConfiguration,
    private val tokenBucketFactory: TokenBucketFactory,
    private val tokenBucketRepository: TokenBucketRepository,
    private val hashFunction: (BucketId) -> Int
) {
  private val mutexes: List<Mutex> = (0 ..< NUMBER_OF_MUTEXES).toList().map { Mutex() }

  suspend fun incrementUsageForIpAddress(ipAddress: IpAddressBucketId): TokenAcquireResult {
    return findOrCreateBucket(ipAddress, singleIpConfig)
  }

  suspend fun incrementGlobalUsage(): TokenAcquireResult {
    return findOrCreateBucket(GlobalBucketId, globalConfig)
  }

  private suspend fun findOrCreateBucket(
      key: BucketId,
      bucketConfig: BucketConfiguration
  ): TokenAcquireResult {
    mutexes[hashFunction(key) % NUMBER_OF_MUTEXES].withLock {
      val bucket =
          tokenBucketRepository.findById(key) ?: tokenBucketFactory.createTokenBucket(bucketConfig)
      val result = bucket.takeOneToken()
      when (result) {
        TokenAcquiredResult -> tokenBucketRepository.save(key, bucket)
        else -> Unit
      }
      return result
    }
  }

  companion object {
    private const val NUMBER_OF_MUTEXES = 100
  }
}

fun hashCodeHash(bucketId: BucketId): Int {
  val hash = bucketId.toRawId().hashCode()
  return if (hash == Int.MIN_VALUE) {
        hash + 1
      } else {
        hash
      }
      .absoluteValue
}
