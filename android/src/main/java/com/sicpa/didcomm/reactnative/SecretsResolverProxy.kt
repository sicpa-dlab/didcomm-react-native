package com.sicpa.didcomm.reactnative

import com.sicpa.didcomm.reactnative.utils.runBlockingWithTimeout
import kotlinx.coroutines.*
import org.didcommx.didcomm.secret.Secret
import org.didcommx.didcomm.secret.SecretResolver
import java.util.*

class SecretsResolverProxy(private val resolversProxyModule: ResolverProxyModule) : SecretResolver {

    companion object {
        private const val TAG = "SecretsResolverProxy"
    }

    private val scope = CoroutineScope(Dispatchers.IO)
    private val foundSecretChannel = resolversProxyModule.foundSecretChannel
    private val foundSecretIdsChannel = resolversProxyModule.foundSecretIdsChannel

    override fun findKey(kid: String): Optional<Secret> {
        var foundSecret: Secret? = null

        val findKeyJob = scope.launch {
            resolversProxyModule.sendEvent(FindKey(kid))
            foundSecret = foundSecretChannel.receive()
        }

        runBlockingWithTimeout(findKeyJob, "${TAG}.findKey")

        return Optional.ofNullable(foundSecret)
    }

    override fun findKeys(kids: List<String>): Set<String> {
        var foundSecrets: Set<String> = emptySet()

        val findKeysJob = scope.launch {
            resolversProxyModule.sendEvent(FindKeys(kids))
            foundSecrets = foundSecretIdsChannel.receive()
        }

        runBlockingWithTimeout(findKeysJob, "${TAG}.findKeys")

        return foundSecrets
    }
}