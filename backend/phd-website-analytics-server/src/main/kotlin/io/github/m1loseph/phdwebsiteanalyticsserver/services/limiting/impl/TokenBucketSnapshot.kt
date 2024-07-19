package io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl

import java.io.Serializable
import java.time.Duration
import java.time.Instant

data class TokenBucketSnapshot(
  val limit: Long,
  val refillTime: Duration,
  val refillAmount: Long,
  val lastRefill: Instant,
  val currentValue: Long,
) : Serializable
