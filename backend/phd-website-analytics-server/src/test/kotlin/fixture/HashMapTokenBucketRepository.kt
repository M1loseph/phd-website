package fixture

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.BucketId
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.TokenBucket
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.TokenBucketRepository

class HashMapTokenBucketRepository : TokenBucketRepository {
  private val tokens = mutableMapOf<BucketId, TokenBucket>()

  override fun findById(id: BucketId): TokenBucket? = tokens[id]

  override fun save(id: BucketId, tokenBucket: TokenBucket) {
    tokens[id] = tokenBucket
  }
}
