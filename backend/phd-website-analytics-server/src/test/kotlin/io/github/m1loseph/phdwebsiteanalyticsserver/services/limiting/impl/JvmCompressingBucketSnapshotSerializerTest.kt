package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization.JvmCompressingBucketSnapshotSerializer
import java.time.Duration
import java.time.Instant
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class JvmCompressingBucketSnapshotSerializerTest {
  private val serializer = JvmCompressingBucketSnapshotSerializer()

  @Test
  fun whenSerializedAndDeserialized_thenContentShouldBeIdentical() {
    val snapshot =
        TokenBucketSnapshot(
            limit = 100L,
            refillTime = Duration.ofSeconds(123),
            refillAmount = 10L,
            lastRefill = Instant.now(),
            currentValue = 10L,
        )

    val serialized = serializer.serialize(snapshot)
    val deserializedSnapshot = serializer.deserialize(serialized)

    assertThat(deserializedSnapshot).isEqualTo(snapshot)
  }
}
