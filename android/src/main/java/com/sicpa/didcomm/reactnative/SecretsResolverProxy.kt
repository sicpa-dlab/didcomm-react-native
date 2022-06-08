package com.sicpa.didcomm.reactnative

import com.sicpa.didcomm.reactnative.utils.runBlockingWithTimeout
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.didcommx.didcomm.secret.Secret
import org.didcommx.didcomm.secret.SecretResolver
import java.util.*

class SecretsResolverProxy(private val resolversProxyModule: ResolversProxyModule, private val resolversId: String) : SecretResolver {

    companion object {
        private const val TAG = "SecretsResolverProxy"
        private val findKeyMutex = Mutex()
        private val findKeysMutex = Mutex()
    }

    private val scope = CoroutineScope(Dispatchers.IO)
    private val foundSecretChannel = resolversProxyModule.foundSecretChannel
    private val foundSecretIdsChannel = resolversProxyModule.foundSecretIdsChannel

    override fun findKey(kid: String): Optional<Secret> {
        var foundSecret: Secret? = null

        val findKeyJob = scope.launch {
            findKeyMutex.withLock {
                resolversProxyModule.sendEvent(FindKey(kid), resolversId)
                foundSecret = foundSecretChannel.receive()
            }
        }

        runBlockingWithTimeout(findKeyJob, "${TAG}.findKey")

        return Optional.ofNullable(foundSecret)
    }

    override fun findKeys(kids: List<String>): Set<String> {
        var foundSecrets: Set<String> = emptySet()

        val findKeysJob = scope.launch {
            findKeysMutex.withLock {
                resolversProxyModule.sendEvent(FindKeys(kids), resolversId)
                foundSecrets = foundSecretIdsChannel.receive()
            }
        }

        runBlockingWithTimeout(findKeysJob, "${TAG}.findKeys")

        return foundSecrets
    }
}