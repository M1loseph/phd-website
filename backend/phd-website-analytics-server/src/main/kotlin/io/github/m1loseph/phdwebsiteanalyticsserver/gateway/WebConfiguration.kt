package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.services.limiting.LimitingService
import io.micrometer.core.instrument.MeterRegistry
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.web.servlet.FilterRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.servlet.config.annotation.CorsRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

@Configuration
@EnableConfigurationProperties(CorsConfiguration::class)
class WebConfiguration(private val corsConfiguration: CorsConfiguration) : WebMvcConfigurer {

  override fun addCorsMappings(registry: CorsRegistry) {
    val allowedOrigins = corsConfiguration.allowedOrigins
    registry.addMapping(corsConfiguration.mapping).allowedOrigins(*allowedOrigins.toTypedArray())
  }

  @Bean
  fun limitingFilterRegistrationBean(
      limitingService: LimitingService,
      meterRegistry: MeterRegistry
  ): FilterRegistrationBean<LimitingFilter> {
    val registrationBean = FilterRegistrationBean<LimitingFilter>()

    registrationBean.setFilter(LimitingFilter(limitingService, meterRegistry))
    registrationBean.addUrlPatterns("/api/v1/analytics/*")

    return registrationBean
  }
}

@ConfigurationProperties("web.cors")
data class CorsConfiguration(
    val mapping: String,
    val allowedOrigins: List<String>
)
