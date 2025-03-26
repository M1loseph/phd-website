package io.github.m1loseph.phdwebsiteanalyticsserver.services.smoke.uri

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.net.URI

class UriBuilderTest {
  @Test
  fun givenUriWithoutQueryParameters_whenNewParametersAreAdded_thenShouldHaveInResultingUri() {
    val uri = URI("http://website.com")
    val uriWithQuery =
      UriBuilder
        .fromURI(uri)
        .withQueryParameter("query1", "value1")
        .withQueryParameter("query2", "value2")
        .build()

    assertThat(uriWithQuery).isEqualTo(URI("http://website.com?query1=value1&query2=value2"))
  }

  @Test
  fun givenUriWithQueryParameters_whenTheSameQueryParamIsAdded_thenShouldBeOverwritten() {
    val uri = URI("http://website.com?query1=value1#fragment")
    val uriWithQuery = UriBuilder.fromURI(uri).withQueryParameter("query1", "changed").build()

    assertThat(uriWithQuery).isEqualTo(URI("http://website.com?query1=changed#fragment"))
  }
}
