package io.github.m1loseph.phdwebsiteanalyticsserver

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication class PhdWebsiteAnalyticsServerApplication

// TODO: write a test that prometheus endpoint is working
fun main(args: Array<String>) {
  runApplication<PhdWebsiteAnalyticsServerApplication>(*args)
}
