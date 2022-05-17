package com.sicpa.didcomm.reactnative

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.didcommx.didcomm.secret.Secret
import org.didcommx.didcomm.secret.SecretResolver
import java.util.*

class SecretsResolverProxy(private val resolversProxyModule: ResolverProxyModule): SecretResolver {
    private val scope = CoroutineScope(Dispatchers.IO)
    private val foundSecretChannel = resolversProxyModule.foundSecretChannel
    private val foundSecretIdsChannel = resolversProxyModule.foundSecretIdsChannel

    override fun findKey(kid: String): Optional<Secret> {
        var foundSecret: Secret? = null

        scope.launch {
            resolversProxyModule.sendEvent(FindKey(kid))
            foundSecret = foundSecretChannel.receive()
        }

        return Optional.ofNullable(foundSecret)
    }
    
    override fun findKeys(kids: List<String>): Set<String> {
        var foundSecrets: Set<String> = emptySet()

        scope.launch {
            resolversProxyModule.sendEvent(FindKeys(kids))
            foundSecrets = foundSecretIdsChannel.receive()
        }

        return foundSecrets
    }
}