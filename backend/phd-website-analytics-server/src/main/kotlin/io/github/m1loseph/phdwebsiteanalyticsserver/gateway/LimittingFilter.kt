package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.*
import io.micrometer.core.instrument.Counter
import io.micrometer.core.instrument.MeterRegistry
import kotlinx.coroutines.runBlocking
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.http.HttpMethod
import org.springframework.http.HttpStatus
import org.springframework.http.HttpStatus.TOO_MANY_REQUESTS
import org.springframework.web.server.ServerWebExchange
import org.springframework.web.server.WebFilter
import org.springframework.web.server.WebFilterChain
import reactor.core.publisher.Mono

class LimitingFilter(private val limitingService: LimitingService, meterRegistry: MeterRegistry) :
    WebFilter {

  private val rejectedNoXForwardedFor: Counter =
      meterRegistry.counter(REJECTED_REQUEST_COUNTER_NAME, REASON_KEY, "no-x-forwarded-for")
  private val rejectedTooManyRequestsSingleIp: Counter =
      meterRegistry.counter(
          REJECTED_REQUEST_COUNTER_NAME, REASON_KEY, "too-many-requests-single-ip")
  private val rejectedTooManyRequestsGlobal: Counter =
      meterRegistry.counter(REJECTED_REQUEST_COUNTER_NAME, REASON_KEY, "too-many-requests-global")

  override fun filter(exchange: ServerWebExchange, chain: WebFilterChain): Mono<Void> {
    val request = exchange.request
    val requestMethod = request.method
    if (HttpMethod.OPTIONS != requestMethod) {
      val xForwardedForHeaderValue = request.headers["X-Forwarded-For"]?.firstOrNull()
      if (xForwardedForHeaderValue == null) {
        logger.warn("Rejected request because there was no X-Forwarded-For header")
        rejectedNoXForwardedFor.increment()
        exchange.response.setStatusCode(HttpStatus.INTERNAL_SERVER_ERROR)
        return Mono.empty()
      }
      val requestIp = IpAddressBucketId(xForwardedForHeaderValue)
      val checks =
          listOf(
              {
                runBlocking {
                  incrementOnFail(
                      rejectedTooManyRequestsSingleIp,
                      limitingService.incrementUsageForIpAddress(requestIp))
                }
              },
              {
                runBlocking {
                  incrementOnFail(
                      rejectedTooManyRequestsGlobal, limitingService.incrementGlobalUsage())
                }
              })
      for (check in checks) {
        when (val checkResult = check()) {
          is TokenDeniedResult -> {
            logger.warn("Reject request because the bucket was drained")
            val remainingTime = checkResult.remainingTime.seconds
            val response = exchange.response
            response.setStatusCode(TOO_MANY_REQUESTS)
            response.headers["Retry-After"] = remainingTime.toString()
            return Mono.empty()
          }
          TokenAcquiredResult -> {
            continue
          }
        }
      }
    }
    return chain.filter(exchange)
  }

  companion object {
    const val REJECTED_REQUEST_COUNTER_NAME = "request.rejected"
    const val REASON_KEY = "reason"
    val logger: Logger = LoggerFactory.getLogger(LimitingFilter::class.java)
  }
}

fun incrementOnFail(counter: Counter, tokenAcquireResult: TokenAcquireResult): TokenAcquireResult {
  if (tokenAcquireResult is TokenDeniedResult) {
    counter.increment()
  }
  return tokenAcquireResult
}
