package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.impl.LimitingService
import io.micrometer.core.instrument.MeterRegistry
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.reactive.config.CorsRegistry
import org.springframework.web.reactive.config.WebFluxConfigurer
import org.springframework.web.server.WebFilter

@Configuration
@EnableConfigurationProperties(CorsConfiguration::class)
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
      { it.toString().startsWith("/api/v1/analytics") },
      LimitingFilter(limitingService, meterRegistry),
    )
  }
}

@ConfigurationProperties("web.cors")
data class CorsConfiguration(val mapping: String, val allowedOrigins: List<String>)
