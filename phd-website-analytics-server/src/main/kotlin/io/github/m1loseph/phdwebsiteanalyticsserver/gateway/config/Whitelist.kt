package io.github.m1loseph.phdwebsiteanalyticsserver.gateway.config

import jakarta.validation.constraints.NotBlank
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.validation.annotation.Validated

@Validated
@ConfigurationProperties("whitelist")
data class Whitelist(
  val users: List<@NotBlank String>
)
