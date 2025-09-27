package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization.BucketSnapshotSerializer
import org.springframework.stereotype.Repository
import redis.clients.jedis.JedisPool
import redis.clients.jedis.params.SetParams

interface TokenBucketRepository {
  fun findById(id: BucketId): TokenBucket?

  fun save(
    id: BucketId,
    tokenBucket: TokenBucket,
  )

  fun clear(id: BucketId)
}

@Repository
class RedisTokenBucketRepository(
  private val tokenBucketFactory: TokenBucketFactory,
  private val jedisPool: JedisPool,
  private val serializer: BucketSnapshotSerializer,
) : TokenBucketRepository {
  override fun findById(id: BucketId): TokenBucket? {
    jedisPool.resource.use { client ->
      val serializedState = client.get(id.toRawId().toByteArray()) ?: return null
      val tokenBucketSnapshot = serializer.deserialize(serializedState)
      return tokenBucketFactory.createTokenBucketFromSnapshot(tokenBucketSnapshot)
    }
  }

  override fun save(
    id: BucketId,
    tokenBucket: TokenBucket,
  ) {
    jedisPool.resource.use { client ->
      tokenBucket.timeToFull()
      val snapshot = tokenBucket.createSnapshot()
      val serialized = serializer.serialize(snapshot)
      client.set(
        id.toRawId().toByteArray(),
        serialized,
        SetParams.setParams().ex(tokenBucket.timeToFull().seconds),
      )
    }
  }

  override fun clear(id: BucketId) {
    jedisPool.resource.use { client ->
      client.del(id.toRawId().toByteArray())
    }
  }
}
