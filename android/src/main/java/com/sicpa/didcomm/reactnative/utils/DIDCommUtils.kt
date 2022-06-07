package com.sicpa.didcomm.reactnative.utils

import org.didcommx.didcomm.message.MessageBuilder

object DIDCommUtils {
    private var emptyMessageBuilder: MessageBuilder? = null

    fun getEmptyMessageBuilder(): MessageBuilder {
        return emptyMessageBuilder ?: run {
            emptyMessageBuilder = MessageBuilder("", mapOf(), "")
            return emptyMessageBuilder as MessageBuilder
        }
    }
}