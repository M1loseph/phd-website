package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model

data class AppVersion(
  val major: Int,
  val minor: Int,
  val commitsAheadOfTag: Int? = null,
  val commitHash: String? = null,
  val rawVersion: String,
)
