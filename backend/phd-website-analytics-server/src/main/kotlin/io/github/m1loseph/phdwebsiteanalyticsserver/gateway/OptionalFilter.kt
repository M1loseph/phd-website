package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import org.springframework.http.server.RequestPath
import org.springframework.web.server.ServerWebExchange
import org.springframework.web.server.WebFilter
import org.springframework.web.server.WebFilterChain
import reactor.core.publisher.Mono

class OptionalFilter(private val rule: (RequestPath) -> Boolean, private val delegate: WebFilter) :
    WebFilter {
  override fun filter(exchange: ServerWebExchange, chain: WebFilterChain): Mono<Void> {
    if (!rule(exchange.request.path)) {
      return chain.filter(exchange)
    }
    return delegate.filter(exchange, chain)
  }
}
