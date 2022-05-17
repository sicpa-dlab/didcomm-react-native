package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.*
import org.didcommx.didcomm.DIDComm
import org.didcommx.didcomm.message.Message
import org.didcommx.didcomm.model.PackEncryptedParams
import org.didcommx.didcomm.model.UnpackParams

class MessageHelpersModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    companion object {
        const val TAG = "DIDCommMessageHelpersModule"
    }

    override fun getName() = "DIDCommMessageHelpers"

    @ReactMethod
    fun pack_encrypted(
        messageData: ReadableMap,
        to: String,
        from: String? = null,
        signFrom: String? = null,
        protectSender: Boolean = true,
        promise: Promise
    ) {
        try {
            val didComm = createDidCommInstance()
            val message = Message.parse(messageData.toHashMap())

            var builder = PackEncryptedParams
                .builder(message, to)
                .forward(false)
                .protectSenderId(protectSender)
            builder = from?.let { builder.from(it) } ?: builder
            builder = signFrom?.let { builder.signFrom(it) } ?: builder

            val packResult = didComm.packEncrypted(builder.build())

            val resultArray = Arguments.createArray().apply {
                pushString(packResult.packedMessage)
                pushMap(Utils.convertObjectToMap(packResult.copy(packedMessage = "null")))
            }

            promise.resolve(resultArray)
        } catch (e: Exception) {
            promise.reject(TAG, "Error on packing DIDComm message", e)
        }
    }

    @ReactMethod
    fun unpack(
        packedMessage: String,
        promise: Promise
    ) {
        try {
            val didComm = createDidCommInstance()

            val unpackResult = didComm.unpack(UnpackParams.Builder(packedMessage).build())

            val resultArray = Arguments.createArray().apply {
                pushMap(Utils.convertObjectToMap(unpackResult.message))
                pushMap(Utils.convertObjectToMap(unpackResult.metadata))
            }

            promise.resolve(resultArray)
        } catch (e: Exception) {
            promise.reject(TAG, "Error on unpacking DIDComm message", e)
        }
    }

    private fun createDidCommInstance(): DIDComm {
        val resolversProxyModule =
            reactContext.getNativeModule(ResolverProxyModule::class.java)
                ?: throw Exception("Error on creating DIDComm instance, resolvers proxy module is not defined")

        return DIDComm(
            DIDDocResolverProxy(resolversProxyModule),
            SecretsResolverProxy(resolversProxyModule)
        )
    }
}