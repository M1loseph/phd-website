package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.TokenBucketSnapshot

class MultipleVersionsAwareSerializer(
  private val defaultSerializer: BucketSnapshotSerializer,
  private val supportedDeserializers: Map<Byte, BucketSnapshotSerializer>,
) : BucketSnapshotSerializer {
  override fun serialize(bucketSnapshot: TokenBucketSnapshot): ByteArray {
    return defaultSerializer.serialize(bucketSnapshot)
  }

  override fun deserialize(serializedTokenBucketSnapshot: ByteArray): TokenBucketSnapshot {
    val version = serializedTokenBucketSnapshot[0]
    return supportedDeserializers[version]!!.deserialize(serializedTokenBucketSnapshot)
  }
}
