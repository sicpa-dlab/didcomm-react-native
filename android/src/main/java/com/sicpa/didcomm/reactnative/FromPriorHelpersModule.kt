package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import com.sicpa.didcomm.reactnative.utils.DIDCommUtils
import com.sicpa.didcomm.reactnative.utils.JsonUtils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.didcommx.didcomm.crypto.key.RecipientKeySelector
import org.didcommx.didcomm.crypto.key.SenderKeySelector
import org.didcommx.didcomm.message.FromPrior
import org.didcommx.didcomm.operations.packFromPrior
import org.didcommx.didcomm.operations.unpackFromPrior

private const val MODULE_NAME = "DIDCommFromPriorHelpersModule"

@ReactModule(name = MODULE_NAME)
class FromPriorHelpersModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName() = MODULE_NAME

    private val scope = CoroutineScope(Dispatchers.Default)

    @ReactMethod
    fun pack(fromPriorData: ReadableMap, issuerKid: String, resolversId: String, promise: Promise) {
        scope.launch {
            try {
                val fromPrior = parseFromPrior(fromPriorData)

                //We need to build empty message with `fromPrior` property to pass it to `packFromPrior`
                //See https://github.com/sicpa-dlab/didcomm-jvm/blob/main/lib/src/main/kotlin/org/didcommx/didcomm/operations/FromPrior.kt#L14
                val message = DIDCommUtils.getEmptyMessageBuilder().fromPrior(fromPrior).build()

                val senderKeySelector = createSenderKeySelectorInstance(resolversId)
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
    fun unpack(fromPriorJwt: String, resolversId: String, promise: Promise) {
        scope.launch {
            try {
                //We need to build empty message with `fromPriorJwt` property to pass it to `unpackFromPrior`
                //See https://github.com/sicpa-dlab/didcomm-jvm/blob/main/lib/src/main/kotlin/org/didcommx/didcomm/operations/FromPrior.kt#L28
                val message =
                    DIDCommUtils.getEmptyMessageBuilder().fromPriorJwt(fromPriorJwt).build()

                val recipientKeySelector = getRecipientKeySelectorInstance(resolversId)
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

    private fun createSenderKeySelectorInstance(resolversId: String): SenderKeySelector {
        val resolversProxyModule =
            reactContext.getNativeModule(ResolversProxyModule::class.java)
                ?: throw Exception("Error on creating SenderKeySelector instance, ResolversProxyModule is not defined")
        return SenderKeySelector(
            DIDDocResolverProxy(resolversProxyModule, resolversId),
            SecretsResolverProxy(resolversProxyModule, resolversId)
        )
    }

    private fun getRecipientKeySelectorInstance(resolversId: String): RecipientKeySelector {
        val resolversProxyModule =
            reactContext.getNativeModule(ResolversProxyModule::class.java)
                ?: throw Exception("Error on creating RecipientKeySelector instance, ResolversProxyModule is not defined")
        return RecipientKeySelector(
            DIDDocResolverProxy(resolversProxyModule, resolversId),
            SecretsResolverProxy(resolversProxyModule, resolversId)
        )
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