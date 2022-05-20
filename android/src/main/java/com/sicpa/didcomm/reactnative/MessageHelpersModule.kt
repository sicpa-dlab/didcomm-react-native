package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.didcommx.didcomm.DIDComm
import org.didcommx.didcomm.message.Message
import org.didcommx.didcomm.model.PackEncryptedParams
import org.didcommx.didcomm.model.UnpackParams

private const val MODULE_NAME = "DIDCommMessageHelpersModule"

@ReactModule(name = MODULE_NAME)
class MessageHelpersModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName() = MODULE_NAME

    private val scope = CoroutineScope(Dispatchers.Default)

    @ReactMethod
    fun pack_encrypted(
        messageData: ReadableMap,
        to: String,
        from: String? = null,
        signFrom: String? = null,
        protectSender: Boolean = true,
        promise: Promise
    ) {
        scope.launch {
            try {
                val message = parseMessage(messageData)

                var builder = PackEncryptedParams
                    .builder(message, to)
                    .forward(false)
                    .protectSenderId(protectSender)
                builder = from?.let { builder.from(it) } ?: builder
                builder = signFrom?.let { builder.signFrom(it) } ?: builder

                val didComm = createDidCommInstance()
                val packResult = didComm.packEncrypted(builder.build())

                val resultArray = Arguments.createArray().apply {
                    pushString(packResult.packedMessage)
                    pushMap(JsonUtils.convertObjectToMap(packResult.copy(packedMessage = "null")))
                }

                promise.resolve(resultArray)
            } catch (e: Throwable) {
                promise.reject(MODULE_NAME, "Error on packing DIDComm message: ${e.message}", e)
            }
        }
    }

    @ReactMethod
    fun unpack(
        packedMessage: String,
        promise: Promise
    ) {
        scope.launch {
            try {
                val didComm = createDidCommInstance()
                val unpackResult = didComm.unpack(UnpackParams.Builder(packedMessage).build())

                val resultArray = Arguments.createArray().apply {
                    pushMap(JsonUtils.convertObjectToMap(unpackResult.message))
                    pushMap(JsonUtils.convertObjectToMap(unpackResult.metadata))
                }

                promise.resolve(resultArray)
            } catch (e: Throwable) {
                promise.reject(MODULE_NAME, "Error on unpacking DIDComm message", e)
            }
        }
    }

    private fun createDidCommInstance(): DIDComm {
        val resolversProxyModule =
            reactContext.getNativeModule(ResolverProxyModule::class.java)
                ?: throw Exception("Error on creating DIDComm instance, ResolverProxyModule is not defined")
        return DIDComm(
            DIDDocResolverProxy(resolversProxyModule),
            SecretsResolverProxy(resolversProxyModule)
        )
    }

    private fun parseMessage(messageData: ReadableMap): Message {
        val messageDataMap = messageData.toHashMap().mapValues {
            when (val value = it.value) {
                is Double -> value.toLong()
                else -> value
            }
        }
        return Message.parse(messageDataMap)
    }
}