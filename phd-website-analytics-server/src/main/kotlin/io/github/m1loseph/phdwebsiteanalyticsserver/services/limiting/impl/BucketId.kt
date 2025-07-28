package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

sealed interface BucketId {
  fun toRawId(): String
}

data object GlobalBucketId : BucketId {
  override fun toRawId(): String = "global"
}

@JvmInline
value class IpAddressBucketId(
  private val rawIpAddress: String,
) : BucketId {
  override fun toRawId(): String = rawIpAddress

  override fun toString(): String = rawIpAddress
}
