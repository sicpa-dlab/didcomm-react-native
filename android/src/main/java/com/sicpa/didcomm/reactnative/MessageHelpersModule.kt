package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import com.sicpa.didcomm.reactnative.utils.JsonUtils
import com.sicpa.didcomm.reactnative.utils.parseAnonCryptAlg
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

    private var didCommInstance: DIDComm? = null
    private var routingInstance: Routing? = null

    @ReactMethod
    fun packEncrypted(
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

                val didComm = getDidCommInstance()
                val packResult = didComm.packEncrypted(builder.build())

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
    fun packSigned(messageData: ReadableMap, signBy: String, promise: Promise) {
        scope.launch {
            try {
                val message = parseMessage(messageData)
                val params = PackSignedParams.builder(message, signBy).build()

                val didComm = getDidCommInstance()
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
    fun packPlaintext(messageData: ReadableMap, promise: Promise) {
        scope.launch {
            try {
                val message = parseMessage(messageData)
                val params = PackPlaintextParams.builder(message).build()

                val didComm = getDidCommInstance()
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
        promise: Promise
    ) {
        scope.launch {
            try {
                val didComm = getDidCommInstance()
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

    @ReactMethod
    fun wrapInForward(
        message: String,
        headers: ReadableMap,
        to: String,
        routingKeys: ReadableArray,
        jsAnonCryptAlg: String,
        promise: Promise
    ) {
        scope.launch {
            try {
                val messageMap = JsonUtils.parseJson(message, Map::class.java) as Map<String, Any>
                val routingKeysList = routingKeys.toArrayList() as List<String>
                val anonCryptAlg = parseAnonCryptAlg(jsAnonCryptAlg)

                val routing = getRoutingInstance()
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

    private fun getDidCommInstance(): DIDComm {
        return didCommInstance ?: run {
            val resolversProxyModule =
                reactContext.getNativeModule(ResolversProxyModule::class.java)
                    ?: throw Exception("Error on creating DIDComm instance, ResolversProxyModule is not defined")

            didCommInstance = DIDComm(
                DIDDocResolverProxy(resolversProxyModule),
                SecretsResolverProxy(resolversProxyModule)
            )

            return didCommInstance as DIDComm
        }
    }

    private fun getRoutingInstance(): Routing {
        return routingInstance ?: run {
            val resolversProxyModule =
                reactContext.getNativeModule(ResolversProxyModule::class.java)
                    ?: throw Exception("Error on creating Routing instance, ResolversProxyModule is not defined")

            routingInstance = Routing(
                DIDDocResolverProxy(resolversProxyModule),
                SecretsResolverProxy(resolversProxyModule)
            )

            return routingInstance as Routing
        }
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