package io.github.m1loseph.phdwebsiteanalyticsserver.gateway.filters

import org.springframework.http.server.RequestPath
import org.springframework.http.server.reactive.ServerHttpRequest
import org.springframework.web.server.ServerWebExchange
import org.springframework.web.server.WebFilter
import org.springframework.web.server.WebFilterChain
import reactor.core.publisher.Mono

class OptionalFilter(private val rule: (ServerHttpRequest) -> Boolean, private val delegate: WebFilter) :
  WebFilter {
  override fun filter(
    exchange: ServerWebExchange,
    chain: WebFilterChain,
  ): Mono<Void> {
    if (!rule(exchange.request)) {
      return chain.filter(exchange)
    }
    return delegate.filter(exchange, chain)
  }
}
