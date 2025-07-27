package io.github.m1loseph.phdwebsiteanalyticsserver.gateway

import io.github.m1loseph.phdwebsiteanalyticsserver.gateway.dto.ErrorDto
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.InvalidVersionException
import io.github.m1loseph.phdwebsiteanalyticsserver.services.analytics.SessionNotFoundException
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler

@ControllerAdvice
class ExceptionsHandler {
  @ExceptionHandler(SessionNotFoundException::class)
  fun handleSessionNotFoundException(ex: SessionNotFoundException): ResponseEntity<ErrorDto> {
    logger.warn("Unable to find session with id {}", ex.sessionId, ex)
    val responseBody =
      ErrorDto(
        code = ex.javaClass.simpleName,
        message = "Unable to find session with id ${ex.sessionId}",
      )
    return ResponseEntity.badRequest().body(responseBody)
  }

  @ExceptionHandler(InvalidVersionException::class)
  fun handleInvalidVersionFormatException(ex: InvalidVersionException): ResponseEntity<ErrorDto> {
    logger.warn("Error occurred while parsing version {}", ex.version, ex)
    val responseBody =
      ErrorDto(
        code = ex.javaClass.simpleName,
        message = "Version ${ex.message} does not have a correct format",
      )
    return ResponseEntity.badRequest().body(responseBody)
  }

  companion object {
    val logger: Logger = LoggerFactory.getLogger(ExceptionsHandler::class.java)
  }
}
