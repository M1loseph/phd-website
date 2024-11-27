package io.github.m1loseph.phdwebsiteanalyticsserver

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.runApplication

@ConfigurationPropertiesScan
@SpringBootApplication class PhdWebsiteAnalyticsServerApplication

fun main(args: Array<String>) {
  runApplication<PhdWebsiteAnalyticsServerApplication>(*args)
}
