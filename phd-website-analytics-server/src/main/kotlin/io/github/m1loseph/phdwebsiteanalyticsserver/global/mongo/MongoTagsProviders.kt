package io.github.m1loseph.phdwebsiteanalyticsserver.global.mongo

import com.mongodb.event.CommandEvent
import com.mongodb.event.ConnectionPoolCreatedEvent
import io.micrometer.core.instrument.Tag
import io.micrometer.core.instrument.binder.mongodb.DefaultMongoCommandTagsProvider
import io.micrometer.core.instrument.binder.mongodb.DefaultMongoConnectionPoolTagsProvider
import io.micrometer.core.instrument.binder.mongodb.MongoCommandTagsProvider
import io.micrometer.core.instrument.binder.mongodb.MongoConnectionPoolTagsProvider

class MongoConnectionPoolConnectionNameTagsProvider(
  private val connectionName: String,
) : MongoConnectionPoolTagsProvider {
  private val delegate = DefaultMongoConnectionPoolTagsProvider()

  override fun connectionPoolTags(cpce: ConnectionPoolCreatedEvent): Iterable<Tag> =
    delegate.connectionPoolTags(cpce).toList() + Tag.of("connection.name", connectionName)
}

class MongoCommandConnectionNameTagsProvider(
  private val connectionName: String,
) : MongoCommandTagsProvider {
  private val delegate = DefaultMongoCommandTagsProvider()

  override fun commandTags(commandEvent: CommandEvent): Iterable<Tag> =
    delegate.commandTags(commandEvent).toList() + Tag.of("connection.name", connectionName)
}
