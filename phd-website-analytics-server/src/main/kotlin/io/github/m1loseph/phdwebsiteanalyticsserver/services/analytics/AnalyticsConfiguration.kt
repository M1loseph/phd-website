package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import java.time.Clock
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class AnalyticsConfiguration {
  @Bean @ConditionalOnMissingBean fun clock(): Clock = Clock.systemUTC()
}
