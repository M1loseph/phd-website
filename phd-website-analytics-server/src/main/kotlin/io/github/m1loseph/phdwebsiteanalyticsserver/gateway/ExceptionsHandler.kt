package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.gateway.dto.ErrorDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.SessionNotFoundException
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.model.InvalidVersionException
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler

@ControllerAdvice
class ExceptionsHandler {
  @ExceptionHandler(SessionNotFoundException::class)
  fun handleSessionNotFoundException(ex: SessionNotFoundException): ResponseEntity<ErrorDto> {
    val responseBody =
      ErrorDto(
        code = ex.javaClass.simpleName,
        message = "Unable to find session with id ${ex.sessionId}",
      )
    return ResponseEntity.badRequest().body(responseBody)
  }

  @ExceptionHandler(InvalidVersionException::class)
  fun handleInvalidVersionFormatException(ex: InvalidVersionException): ResponseEntity<ErrorDto> {
    val responseBody =
      ErrorDto(
        code = ex.javaClass.simpleName,
        message = "Version ${ex.invalidVersion} does not have a correct format",
      )
    return ResponseEntity.badRequest().body(responseBody)
  }
}
