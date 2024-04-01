package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.TokenBucketSnapshot

class VersionedBucketSnapshotSerializer(
    private val version: Byte,
    private val delegate: BucketSnapshotSerializer
) : BucketSnapshotSerializer {
  override fun serialize(bucketSnapshot: TokenBucketSnapshot): ByteArray {
    val serialized = delegate.serialize(bucketSnapshot)
    val buffer = ByteArray(serialized.size + 1)
    buffer[0] = version
    for (i in serialized.indices) {
      buffer[i + 1] = serialized[i]
    }
    return buffer
  }

  override fun deserialize(serializedTokenBucketSnapshot: ByteArray): TokenBucketSnapshot {
    assert(serializedTokenBucketSnapshot[0] == version)
    return delegate.deserialize(
        serializedTokenBucketSnapshot.copyOfRange(1, serializedTokenBucketSnapshot.size))
  }

  companion object {
    const val JVM_COMPRESSING_BUCKET_SNAPSHOT_SERIALIZER: Byte = 1
  }
}
