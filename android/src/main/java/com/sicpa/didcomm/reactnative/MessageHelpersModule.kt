package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import com.sicpa.didcomm.reactnative.model.JSPackEncryptedOptions
import com.sicpa.didcomm.reactnative.model.JSUnpackOptions
import com.sicpa.didcomm.reactnative.utils.JsonUtils
import com.sicpa.didcomm.reactnative.utils.parseAnonCryptAlg
import com.sicpa.didcomm.reactnative.utils.parseAuthCryptAlg
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.didcommx.didcomm.DIDComm
import org.didcommx.didcomm.message.Message
import org.didcommx.didcomm.model.PackEncryptedParams
import org.didcommx.didcomm.model.PackPlaintextParams
import org.didcommx.didcomm.model.PackSignedParams
import org.didcommx.didcomm.model.UnpackParams
import org.didcommx.didcomm.protocols.routing.Routing

private const val MODULE_NAME = "DIDCommMessageHelpersModule"

@ReactModule(name = MODULE_NAME)
class MessageHelpersModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName() = MODULE_NAME

    private val scope = CoroutineScope(Dispatchers.Default)

    @ReactMethod
    fun packEncrypted(
        messageData: ReadableMap,
        to: String,
        from: String? = null,
        signFrom: String? = null,
        optionsJson: String? = null,
        resolversId: String,
        promise: Promise
    ) {
        scope.launch {
            try {
                val message = parseMessage(messageData)
                val options =
                    optionsJson?.let { JsonUtils.parseJson(it, JSPackEncryptedOptions::class.java) }

                val paramsBuilder = PackEncryptedParams
                    .builder(message, to)
                    .apply {
                        from?.let { from(it) }
                        signFrom?.let { signFrom(it) }
                    }

                if (options != null) {
                    paramsBuilder.apply {
                        options.protect_sender?.let { protectSenderId(it) }
                        options.forward?.let { forward(it) }
                        options.forward_headers?.let { forwardHeaders(it) }
                        options.messaging_service?.let { forwardServiceId(it) }
                        options.enc_alg_auth?.let { encAlgAuth(parseAuthCryptAlg(it)) }
                        options.enc_alg_anon?.let { encAlgAnon(parseAnonCryptAlg(it)) }
                    }
                }

                val didComm = createDidCommInstance(resolversId)
                val packResult = didComm.packEncrypted(paramsBuilder.build())

                val resultArray = Arguments.createArray().apply {
                    pushString(packResult.packedMessage)
                    pushMap(JsonUtils.convertObjectToMap(packResult.copy(packedMessage = "null")))
                }

                promise.resolve(resultArray)
            } catch (e: Throwable) {
                promise.reject(
                    MODULE_NAME,
                    "Error on packing encrypted DIDComm message: ${e.message}",
                    e
                )
            }
        }
    }

    @ReactMethod
    fun packSigned(
        messageData: ReadableMap,
        signBy: String,
        resolversId: String,
        promise: Promise
    ) {
        scope.launch {
            try {
                val message = parseMessage(messageData)
                val params = PackSignedParams.builder(message, signBy).build()

                val didComm = createDidCommInstance(resolversId)
                val packResult = didComm.packSigned(params)

                val resultArray = Arguments.createArray().apply {
                    pushString(packResult.packedMessage)
                    pushMap(JsonUtils.convertObjectToMap(packResult.copy(packedMessage = "null")))
                }

                promise.resolve(resultArray)
            } catch (e: Throwable) {
                promise.reject(
                    MODULE_NAME,
                    "Error on packing signed DIDComm message: ${e.message}",
                    e
                )
            }
        }
    }

    @ReactMethod
    fun packPlaintext(messageData: ReadableMap, resolversId: String, promise: Promise) {
        scope.launch {
            try {
                val message = parseMessage(messageData)
                val params = PackPlaintextParams.builder(message).build()

                val didComm = createDidCommInstance(resolversId)
                val packResult = didComm.packPlaintext(params)

                promise.resolve(packResult.packedMessage)
            } catch (e: Throwable) {
                promise.reject(
                    MODULE_NAME,
                    "Error on packing plaintext DIDComm message: ${e.message}",
                    e
                )
            }
        }
    }

    @ReactMethod
    fun unpack(
        packedMessage: String,
        optionsJson: String?,
        resolversId: String,
        promise: Promise
    ) {
        scope.launch {
            try {
                val options =
                    optionsJson?.let { JsonUtils.parseJson(it, JSUnpackOptions::class.java) }

                val paramsBuilder = UnpackParams.Builder(packedMessage)

                if (options != null) {
                    paramsBuilder.apply {
                        options.expect_decrypt_by_all_keys?.let { expectDecryptByAllKeys(it) }
                        options.unwrap_re_wrapping_forward?.let { unwrapReWrappingForward(it) }
                    }
                }

                val didComm = createDidCommInstance(resolversId)
                val unpackResult = didComm.unpack(paramsBuilder.build())

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

    @ReactMethod
    fun wrapInForward(
        message: String,
        headers: ReadableMap,
        to: String,
        routingKeys: ReadableArray,
        jsAnonCryptAlg: String,
        resolversId: String,
        promise: Promise
    ) {
        scope.launch {
            try {
                val messageMap = JsonUtils.parseJson(message, Map::class.java) as Map<String, Any>
                val routingKeysList = routingKeys.toArrayList() as List<String>
                val anonCryptAlg = parseAnonCryptAlg(jsAnonCryptAlg)

                val routing = createRoutingInstance(resolversId)
                val wrapResult = routing.wrapInForward(
                    messageMap,
                    to,
                    anonCryptAlg,
                    routingKeysList,
                    headers.toHashMap()
                )

                promise.resolve(wrapResult?.msgEncrypted?.packedMessage)
            } catch (e: Throwable) {
                promise.reject(MODULE_NAME, "Error on wrapping DIDComm message in forward", e)
            }
        }
    }

    private fun createDidCommInstance(resolversId: String): DIDComm {
        val resolversProxyModule =
            reactContext.getNativeModule(ResolversProxyModule::class.java)
                ?: throw Exception("Error on creating DIDComm instance, ResolversProxyModule is not defined")
        return DIDComm(
            DIDDocResolverProxy(resolversProxyModule, resolversId),
            SecretsResolverProxy(resolversProxyModule, resolversId)
        )
    }

    private fun createRoutingInstance(resolversId: String): Routing {
        val resolversProxyModule =
            reactContext.getNativeModule(ResolversProxyModule::class.java)
                ?: throw Exception("Error on creating Routing instance, ResolversProxyModule is not defined")
        return Routing(
            DIDDocResolverProxy(resolversProxyModule, resolversId),
            SecretsResolverProxy(resolversProxyModule, resolversId)
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