package com.sicpa.didcomm.reactnative

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
                resolversProxyModule.sendEvent(ResolveDid(did), resolversId)
                resolvedDid = resolvedDidChannel.receive()
            }
        }

        runBlockingWithTimeout(resolveDidJob, "${TAG}.resolve")

        return Optional.ofNullable(resolvedDid)
    }
}