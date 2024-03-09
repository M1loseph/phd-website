package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke.SmokeTestResult
import io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke.SmokeTestsService
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/internal/tests/smoke")
class SmokeTestsController(private val smokeTestsService: SmokeTestsService) {

  @GetMapping("/redis")
  fun testIfConnectionToRedisIsAlive(): ResponseEntity<Void> {
    return when (smokeTestsService.testIfConnectionToRedisIsAlive()) {
      SmokeTestResult.OK -> ResponseEntity(HttpStatus.OK)
      SmokeTestResult.ERROR -> ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR)
    }
  }

  @GetMapping("/mongodb")
  fun testIfConnectionToMongodbIsAlive(): ResponseEntity<Void> {
    return when (smokeTestsService.testIfConnectionToMongodbIsAlive()) {
      SmokeTestResult.OK -> ResponseEntity(HttpStatus.OK)
      SmokeTestResult.ERROR -> ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR)
    }
  }

  companion object {
    val logger: Logger = LoggerFactory.getLogger(SmokeTestsController::class.java)
  }
}
