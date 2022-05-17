package com.sicpa.didcomm.reactnative

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch
import org.didcommx.didcomm.diddoc.DIDDoc
import org.didcommx.didcomm.diddoc.DIDDocResolver
import java.util.*

class DIDDocResolverProxy(private val resolversProxyModule: ResolverProxyModule): DIDDocResolver {
    private val scope = CoroutineScope(Dispatchers.IO)
    private val resolvedDidChannel = resolversProxyModule.resolvedDidChannel

    override fun resolve(did: String): Optional<DIDDoc> {
        var resolvedDid: DIDDoc? = null

        scope.launch {
            resolversProxyModule.sendEvent(ResolveDid(did))
            resolvedDid = resolvedDidChannel.receive()
        }

        return Optional.ofNullable(resolvedDid)
    }
}