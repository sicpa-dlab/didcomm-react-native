package com.sicpa.didcomm.reactnative

import android.util.Log
import kotlinx.coroutines.*
import org.didcommx.didcomm.diddoc.DIDDoc
import org.didcommx.didcomm.diddoc.DIDDocResolver
import java.util.*

class DIDDocResolverProxy(private val resolversProxyModule: ResolverProxyModule) : DIDDocResolver {

    companion object {
        private const val TAG = "DIDDocResolverProxy"
    }

    private val scope = CoroutineScope(Dispatchers.IO)
    private val resolvedDidChannel = resolversProxyModule.resolvedDidChannel

    override fun resolve(did: String): Optional<DIDDoc> {
        var resolvedDid: DIDDoc? = null

        runBlocking {
            try {
                withTimeout(1500) {
                    scope.launch {
                        resolversProxyModule.sendEvent(ResolveDid(did))
                        resolvedDid = resolvedDidChannel.receive()
                    }.join()
                }
            } catch (e: TimeoutCancellationException) {
                Log.e(TAG, "Resolve Did operation timed out")
            }
        }

        return Optional.ofNullable(resolvedDid)
    }
}