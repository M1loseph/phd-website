package io.github.m1loseph.phdwebsiteanalyticsserver

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication class PhdWebsiteAnalyticsServerApplication

fun main(args: Array<String>) {
  runApplication<PhdWebsiteAnalyticsServerApplication>(*args)
}
