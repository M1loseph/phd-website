package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.serialization

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.TokenBucketSnapshot
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.util.zip.GZIPInputStream
import java.util.zip.GZIPOutputStream

class JvmCompressingBucketSnapshotSerializer : BucketSnapshotSerializer {
  override fun serialize(bucketSnapshot: TokenBucketSnapshot): ByteArray {
    val byteArrayOutputStream = ByteArrayOutputStream()
    GZIPOutputStream(byteArrayOutputStream).use {
      val serializer = ObjectOutputStream(it)
      serializer.writeObject(bucketSnapshot)
    }
    return byteArrayOutputStream.toByteArray()
  }

  override fun deserialize(serializedTokenBucketSnapshot: ByteArray): TokenBucketSnapshot {
    val deserializer =
        ObjectInputStream(GZIPInputStream(ByteArrayInputStream(serializedTokenBucketSnapshot)))
    return deserializer.readObject() as TokenBucketSnapshot
  }
}
