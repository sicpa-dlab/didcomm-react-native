package com.sicpa.didcomm.reactnative

import com.sicpa.didcomm.reactnative.utils.runBlockingWithTimeout
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

        val resolveDidJob = scope.launch {
            resolversProxyModule.sendEvent(ResolveDid(did))
            resolvedDid = resolvedDidChannel.receive()
        }

        runBlockingWithTimeout(resolveDidJob, "${TAG}.resolve")

        return Optional.ofNullable(resolvedDid)
    }
}