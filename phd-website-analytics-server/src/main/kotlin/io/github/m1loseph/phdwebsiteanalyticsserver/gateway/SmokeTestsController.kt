package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke.SmokeTestResult
import io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke.SmokeTestsService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/internal/tests/smoke")
class SmokeTestsController(private val smokeTestsService: SmokeTestsService) {
  @GetMapping("/redis")
  suspend fun testIfConnectionToRedisIsAlive(): ResponseEntity<Void> {
    return when (smokeTestsService.testIfConnectionToRedisIsAlive()) {
      SmokeTestResult.OK -> ResponseEntity(HttpStatus.OK)
      SmokeTestResult.ERROR -> ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR)
    }
  }

  @GetMapping("/mongodb")
  suspend fun testIfConnectionToMongodbIsAlive(): ResponseEntity<Void> {
    return when (smokeTestsService.testIfConnectionToMongodbIsAlive()) {
      SmokeTestResult.OK -> ResponseEntity(HttpStatus.OK)
      SmokeTestResult.ERROR -> ResponseEntity(HttpStatus.INTERNAL_SERVER_ERROR)
    }
  }
}
