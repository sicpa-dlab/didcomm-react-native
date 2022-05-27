package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import com.sicpa.didcomm.reactnative.utils.JsonUtils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.didcommx.didcomm.crypto.key.RecipientKeySelector
import org.didcommx.didcomm.crypto.key.SenderKeySelector
import org.didcommx.didcomm.message.FromPrior
import org.didcommx.didcomm.message.MessageBuilder
import org.didcommx.didcomm.operations.packFromPrior
import org.didcommx.didcomm.operations.unpackFromPrior

private const val MODULE_NAME = "DIDCommFromPriorHelpersModule"

@ReactModule(name = MODULE_NAME)
class FromPriorHelpersModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName() = MODULE_NAME

    private val scope = CoroutineScope(Dispatchers.Default)

    private var senderKeySelectorInstance: SenderKeySelector? = null
    private var recipientKeySelectorInstance: RecipientKeySelector? = null

    @ReactMethod
    fun pack(fromPriorData: ReadableMap, issuerKid: String, promise: Promise) {
        scope.launch {
            try {
                val fromPrior = parseFromPrior(fromPriorData)
                val message = MessageBuilder("", mapOf(), "").fromPrior(fromPrior).build()

                val senderKeySelector = getSenderKeySelectorInstance()
                val packResult = packFromPrior(message, issuerKid, senderKeySelector)

                val resultArray = Arguments.createArray().apply {
                    pushString(packResult.first.fromPriorJwt)
                    pushString(packResult.second)
                }

                promise.resolve(resultArray)
            } catch (e: Throwable) {
                promise.reject(
                    MODULE_NAME,
                    "Error on packing FromPrior: ${e.message}",
                    e
                )
            }
        }
    }

    @ReactMethod
    fun unpack(fromPriorJwt: String, promise: Promise) {
        scope.launch {
            try {
                val message = MessageBuilder("", mapOf(), "").fromPriorJwt(fromPriorJwt).build()

                val recipientKeySelector = getRecipientKeySelectorInstance()
                val unpackResult = unpackFromPrior(message, recipientKeySelector)

                val resultArray = Arguments.createArray().apply {
                    unpackResult.first.fromPrior?.let {
                        pushMap(
                            JsonUtils.convertObjectToMap(it)
                        )
                    }
                    pushString(unpackResult.second)
                }

                promise.resolve(resultArray)
            } catch (e: Throwable) {
                promise.reject(
                    MODULE_NAME,
                    "Error on unpacking FromPrior: ${e.message}",
                    e
                )
            }
        }
    }

    private fun getSenderKeySelectorInstance(): SenderKeySelector {
        return senderKeySelectorInstance ?: run {
            val resolversProxyModule =
                reactContext.getNativeModule(ResolversProxyModule::class.java)
                    ?: throw Exception("Error on creating SenderKeySelector instance, ResolversProxyModule is not defined")

            senderKeySelectorInstance = SenderKeySelector(
                DIDDocResolverProxy(resolversProxyModule),
                SecretsResolverProxy(resolversProxyModule)
            )

            return senderKeySelectorInstance as SenderKeySelector
        }
    }

    private fun getRecipientKeySelectorInstance(): RecipientKeySelector {
        return recipientKeySelectorInstance ?: run {
            val resolversProxyModule =
                reactContext.getNativeModule(ResolversProxyModule::class.java)
                    ?: throw Exception("Error on creating RecipientKeySelector instance, ResolversProxyModule is not defined")

            recipientKeySelectorInstance = RecipientKeySelector(
                DIDDocResolverProxy(resolversProxyModule),
                SecretsResolverProxy(resolversProxyModule)
            )

            return recipientKeySelectorInstance as RecipientKeySelector
        }
    }

    private fun parseFromPrior(fromPriorData: ReadableMap): FromPrior? {
        val fromPriorDataMap = fromPriorData.toHashMap().mapValues {
            when (val value = it.value) {
                is Double -> value.toLong()
                else -> value
            }
        }
        return FromPrior.parse(fromPriorDataMap)
    }
}