package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.TokenBucketSnapshot

interface BucketSnapshotSerializer {
  fun serialize(bucketSnapshot: TokenBucketSnapshot): ByteArray

  fun deserialize(serializedTokenBucketSnapshot: ByteArray): TokenBucketSnapshot
}
