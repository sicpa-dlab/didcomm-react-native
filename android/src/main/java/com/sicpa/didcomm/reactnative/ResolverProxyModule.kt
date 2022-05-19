package com.sicpa.didcomm.reactnative

import android.util.Log
import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.google.gson.GsonBuilder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch
import org.didcommx.didcomm.diddoc.DIDDoc
import org.didcommx.didcomm.secret.Secret

private const val MODULE_NAME = "ResolverProxyModule"

@ReactModule(name = MODULE_NAME)
class ResolverProxyModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName() = MODULE_NAME

    companion object {
        private const val DID_STRING_KEY = "did"
        private const val KID_STRING_KEY = "kid"
        private const val KIDS_STRING_KEY = "kids"
    }

    private val scope = CoroutineScope(Dispatchers.IO)
    val resolvedDidChannel = Channel<DIDDoc>(0)
    val foundSecretChannel = Channel<Secret>(0)
    val foundSecretIdsChannel = Channel<Set<String>>(0)

    @ReactMethod
    fun setResolvedDid(value: ReadableMap) {
        scope.launch {
            val didDoc = Utils.mapObject<ReadableMap, DIDDoc>(value)
            resolvedDidChannel.send(didDoc)
        }
    }

    @ReactMethod
    fun setFoundSecret(value: ReadableMap) {
        scope.launch {
            val secret = Utils.mapObject<ReadableMap, Secret>(value)
            foundSecretChannel.send(secret)
        }
    }

    @ReactMethod
    fun setFoundSecretIds(values: ReadableArray) {
        scope.launch {
            val secretIds = Utils.mapObject<ReadableArray, Set<String>>(values)
            foundSecretIdsChannel.send(secretIds)
        }
    }

    @ReactMethod
    fun addListener(eventName: String) {
        // Set up any upstream listeners or background tasks as necessary
    }

    @ReactMethod
    fun removeListeners(count: Int) {
        // Remove upstream listeners, stop unnecessary background tasks
    }

    fun sendEvent(event: ResolverProxyEvent) {
        val params = Arguments.createMap().apply {
            when (event) {
                is ResolveDid -> putString(DID_STRING_KEY, event.did)
                is FindKey -> putString(KID_STRING_KEY, event.kid)
                is FindKeys -> putArray(KIDS_STRING_KEY, Arguments.fromList(event.kids))
            }
        }
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java).emit(
            event.type, params
        )
        Log.d(MODULE_NAME, "Event sent to React Native: ${event.type}")
    }

    override fun getConstants(): MutableMap<String, Any>? {
        return mutableMapOf(
            "DID_STRING_KEY" to DID_STRING_KEY,
            "KID_STRING_KEY" to KID_STRING_KEY,
            "KIDS_STRING_KEY" to KIDS_STRING_KEY
        )
    }

}