package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import java.time.Clock

@Configuration
class AnalyticsConfiguration {
  @Bean @ConditionalOnMissingBean
  fun clock(): Clock = Clock.systemUTC()
}
