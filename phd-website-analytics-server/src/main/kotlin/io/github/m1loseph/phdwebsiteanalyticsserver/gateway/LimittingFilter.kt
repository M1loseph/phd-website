package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.IpAddress
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.LimitingService
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.RateLimitingResult
import io.micrometer.core.instrument.Counter
import io.micrometer.core.instrument.MeterRegistry
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpFilter
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.http.HttpMethod
import org.springframework.http.HttpStatus.TOO_MANY_REQUESTS

class LimitingFilter(private val limitingService: LimitingService, meterRegistry: MeterRegistry) : HttpFilter() {
  private val rejectedNoXForwardedFor: Counter = meterRegistry.counter(REJECTED_REQUEST_COUNTER_NAME, REASON_KEY, "no-x-forwarded-for")
  private val rejectedTooManyRequestsSingleIp: Counter = meterRegistry.counter(REJECTED_REQUEST_COUNTER_NAME, REASON_KEY, "too-many-requests-single-ip")
  private val rejectedTooManyRequestsGlobal: Counter = meterRegistry.counter(REJECTED_REQUEST_COUNTER_NAME, REASON_KEY, "too-many-requests-global")

  override fun doFilter(
      request: HttpServletRequest,
      response: HttpServletResponse,
      chain: FilterChain
  ) {
    val requestMethod = request.method
    if (!HttpMethod.OPTIONS.matches(requestMethod)) {
      val xForwardedForHeaderValue: String? = request.getHeader("X-Forwarded-For")
      if (xForwardedForHeaderValue == null) {
        logger.warn("Rejected request because there was no X-Forwarded-For header")
        rejectedNoXForwardedFor.increment()
        response.status = 503
        return
      }
      val requestIp = IpAddress(xForwardedForHeaderValue)
      val checks = listOf(
          { incrementOnFail(rejectedTooManyRequestsSingleIp, limitingService.incrementUsageForIpAddress(requestIp)) },
          { incrementOnFail(rejectedTooManyRequestsGlobal, limitingService.incrementGlobalUsage()) }
      )
      for (check in checks) {
        val checkResult = check()
        if (checkResult.success) {
          continue
        }
        logger.warn("Reject request because the bucket was drained")
        response.status = TOO_MANY_REQUESTS.value()
        response.setHeader("Retry-After", checkResult.timeToNextPossibleCall.seconds.toString())
        return
      }
    }
    chain.doFilter(request, response)
  }


  companion object {
    const val REJECTED_REQUEST_COUNTER_NAME = "request.rejected"
    const val REASON_KEY = "reason"
    val logger: Logger = LoggerFactory.getLogger(LimitingFilter::class.java)
  }
}

fun incrementOnFail(counter: Counter, rateLimitingResult: RateLimitingResult): RateLimitingResult {
  if (!rateLimitingResult.success) {
    counter.increment()
  }
  return rateLimitingResult
}
