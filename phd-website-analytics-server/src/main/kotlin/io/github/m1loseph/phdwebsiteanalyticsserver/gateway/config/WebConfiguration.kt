package io.github.m1loseph.phdwebsiteanalyticsserver.gateway.config

import io.github.m1loseph.phdwebsiteanalyticsserver.gateway.filters.LimitingFilter
import io.github.m1loseph.phdwebsiteanalyticsserver.gateway.filters.OptionalFilter
import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.LimitingService
import io.micrometer.core.instrument.MeterRegistry
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.security.config.web.server.invoke;
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.Customizer.withDefaults
import org.springframework.security.config.annotation.web.configurers.DefaultLoginPageConfigurer
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity
import org.springframework.security.config.web.server.ServerHttpSecurity
import org.springframework.security.web.server.SecurityWebFilterChain
import org.springframework.web.reactive.config.CorsRegistry
import org.springframework.web.reactive.config.WebFluxConfigurer
import org.springframework.web.server.WebFilter

@Configuration
class WebConfiguration(private val corsConfiguration: CorsConfiguration) : WebFluxConfigurer {
  override fun addCorsMappings(registry: CorsRegistry) {
    val allowedOrigins = corsConfiguration.allowedOrigins
    registry.addMapping(corsConfiguration.mapping).allowedOrigins(*allowedOrigins.toTypedArray())
  }

  @Bean
  fun limitingFilter(
    limitingService: LimitingService,
    meterRegistry: MeterRegistry,
  ): WebFilter {
    return OptionalFilter(
      { it.path.value().startsWith("/api/v1/analytics") && it.method == HttpMethod.POST },
      LimitingFilter(limitingService, meterRegistry),
    )
  }
}

@ConfigurationProperties("web.cors")
data class CorsConfiguration(val mapping: String, val allowedOrigins: List<String>)

@Configuration
@EnableWebFluxSecurity
class SecurityConfig {

  @Bean
  // TODO: issues
  // 1. /login -> I don't want that
  // 2. Authentication interface - how to use it
  // 3. Authorization - how to protect spring resources
  fun securityWebFilterChain(http: ServerHttpSecurity): SecurityWebFilterChain {
    return http {
      authorizeExchange {
        authorize("/api/v1/analytics/appOpened", permitAll)
        authorize("/api/v1/analytics/pageOpened", permitAll)
        authorize("/internal/**", permitAll)
        authorize(anyExchange, authenticated)
      }
      csrf {
        // TODO: enable me
        disable()
      }
      oauth2Login { }
    }
  }
}
