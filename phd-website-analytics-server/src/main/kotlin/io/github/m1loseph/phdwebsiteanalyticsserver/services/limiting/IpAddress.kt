package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting

@JvmInline
value class IpAddress(val rawIpAddress: String) {
  override fun toString(): String {
    return rawIpAddress
  }
}
