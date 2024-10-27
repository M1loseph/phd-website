package io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke.uri

import java.net.URI

class UriBuilder(
  private val scheme: String?,
  private val userInfo: String?,
  private val host: String?,
  private val port: Int,
  private val path: String?,
  private val queryParams: MutableMap<String, String>,
  private val fragment: String?,
) {
  fun withQueryParameter(
    key: String,
    value: String,
  ): UriBuilder {
    queryParams[key] = value
    return this
  }

  fun build(): URI {
    val queryParametersPart =
      if (queryParams.isEmpty()) {
        null
      } else {
        queryParams.asSequence().map { "${it.key}=${it.value}" }.joinToString("&")
      }

    return URI(scheme, userInfo, host, port, path, queryParametersPart, fragment)
  }

  companion object {
    fun fromURI(uri: URI): UriBuilder {
      val queryParams =
        (uri.query ?: "")
          .split("&")
          .filter { it.isNotBlank() }
          .map { it.split("=") }
          .associateTo(mutableMapOf()) { Pair(it[0], it[1]) }

      return UriBuilder(
        uri.scheme,
        uri.userInfo,
        uri.host,
        uri.port,
        uri.path,
        queryParams,
        uri.fragment,
      )
    }
  }
}
