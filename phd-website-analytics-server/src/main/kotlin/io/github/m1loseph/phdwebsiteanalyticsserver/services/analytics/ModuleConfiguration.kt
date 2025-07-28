package io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class ModuleConfiguration {
  @Bean
  fun appVersionParser(): AppVersionParser = ManualAppVersionParser()
}
