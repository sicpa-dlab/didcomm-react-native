package com.sicpa.didcomm.reactnative

import android.util.Log
import com.sicpa.didcomm.reactnative.model.*
import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.sicpa.didcomm.reactnative.utils.JsonUtils
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.channels.ReceiveChannel
import kotlinx.coroutines.launch
import org.didcommx.didcomm.diddoc.DIDDoc
import org.didcommx.didcomm.secret.Secret

private const val MODULE_NAME = "DIDCommResolversProxyModule"

@ReactModule(name = MODULE_NAME)
class ResolversProxyModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName() = MODULE_NAME

    companion object {
        private const val DID_STRING_KEY = "did"
        private const val KID_STRING_KEY = "kid"
        private const val KIDS_STRING_KEY = "kids"
        private const val RESOLVERS_ID_STRING_KEY = "resolversId"
    }

    private val scope = CoroutineScope(Dispatchers.IO)

    private val _resolvedDidChannel = Channel<DIDDoc?>(0)
    private val _foundSecretChannel = Channel<Secret?>(0)
    private val _foundSecretIdsChannel = Channel<Set<String>>(0)

    val resolvedDidChannel
        get() = _resolvedDidChannel as ReceiveChannel<DIDDoc?>
    val foundSecretChannel
        get() = _foundSecretChannel as ReceiveChannel<Secret?>
    val foundSecretIdsChannel
        get() = _foundSecretIdsChannel as ReceiveChannel<Set<String>>

    @ReactMethod
    fun setResolvedDid(jsonValue: String?, setResolvedDid: String) {
        scope.launch {
            val jsDidDoc = jsonValue?.let { JsonUtils.parseJson(jsonValue, JSDIDDoc::class.java) }
            _resolvedDidChannel.send(jsDidDoc?.toDIDDoc())
        }
    }

    @ReactMethod
    fun setFoundSecret(jsonValue: String?, setResolvedDid: String) {
        scope.launch {
            val jsSecret = jsonValue?.let { JsonUtils.parseJson(jsonValue, JSSecret::class.java) }
            _foundSecretChannel.send(jsSecret?.toSecret())
        }
    }

    @ReactMethod
    fun setFoundSecretIds(jsonValue: String?, setResolvedDid: String) {
        scope.launch {
            val secretIds = jsonValue?.let { JsonUtils.parseJson(jsonValue, Set::class.java) }
            _foundSecretIdsChannel.send(secretIds as? Set<String> ?: emptySet())
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

    fun sendEvent(event: ResolverProxyEvent, resolversId: String) {
        val params = Arguments.createMap().apply {
            when (event) {
                is ResolveDid -> putString(DID_STRING_KEY, event.did)
                is FindKey -> putString(KID_STRING_KEY, event.kid)
                is FindKeys -> putArray(KIDS_STRING_KEY, Arguments.fromList(event.kids))
            }
            putString(RESOLVERS_ID_STRING_KEY, resolversId)
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
            "KIDS_STRING_KEY" to KIDS_STRING_KEY,
            "RESOLVERS_ID_STRING_KEY" to RESOLVERS_ID_STRING_KEY
        )
    }

}