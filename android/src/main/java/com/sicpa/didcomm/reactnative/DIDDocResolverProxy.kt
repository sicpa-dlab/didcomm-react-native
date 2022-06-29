package com.sicpa.didcomm.reactnative

import android.util.Log
import com.sicpa.didcomm.reactnative.utils.runBlockingWithTimeout
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.didcommx.didcomm.diddoc.DIDDoc
import org.didcommx.didcomm.diddoc.DIDDocResolver
import java.util.*

class DIDDocResolverProxy(private val resolversProxyModule: ResolversProxyModule, private val resolversId: String) : DIDDocResolver {

    companion object {
        private const val TAG = "DIDDocResolverProxy"
        private val resolveMutex = Mutex()
    }

    private val scope = CoroutineScope(Dispatchers.IO)
    private val resolvedDidChannel = resolversProxyModule.resolvedDidChannel

    override fun resolve(did: String): Optional<DIDDoc> {
        var resolvedDid: DIDDoc? = null

        val resolveDidJob = scope.launch {
            resolveMutex.withLock {
                resolvedDid = resolveDidFromProxy(did)

                // Additional logs and retry logic for debugging. Related to #937
                if (resolvedDid?.did != did) {
                    Log.e(
                        TAG,
                        "Got invalid DIDDoc from proxy. Requested DID: ${did}, Result DID: ${resolvedDid?.did}. Retrying..."
                    )
                    resolvedDid = resolveDidFromProxy(did)
                    if (resolvedDid?.did != did) Log.e(
                        TAG,
                        "Got invalid DIDDoc on retry. Requested DID: ${did}, Result DID: ${resolvedDid?.did}"
                    )
                }
            }
        }

        runBlockingWithTimeout(resolveDidJob, "${TAG}.resolve")

        return Optional.ofNullable(resolvedDid)
    }

    private suspend fun resolveDidFromProxy(did: String): DIDDoc? {
        resolversProxyModule.sendEvent(ResolveDid(did), resolversId)
        return resolvedDidChannel.receive()
    }
}