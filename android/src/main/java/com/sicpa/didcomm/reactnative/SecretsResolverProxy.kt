package com.sicpa.didcomm.reactnative

import android.util.Log
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

        runBlocking {
            try {
                withTimeout(1500) {
                    scope.launch {
                        resolversProxyModule.sendEvent(FindKey(kid))
                        foundSecret = foundSecretChannel.receive()
                    }.join()
                }
            } catch (e: TimeoutCancellationException) {
                Log.e(TAG, "Find key operation timed out")
            }
        }

        return Optional.ofNullable(foundSecret)
    }

    override fun findKeys(kids: List<String>): Set<String> {
        var foundSecrets: Set<String> = emptySet()

        runBlocking {
            try {
                withTimeout(1500) {
                    scope.launch {
                        resolversProxyModule.sendEvent(FindKeys(kids))
                        foundSecrets = foundSecretIdsChannel.receive()
                    }.join()
                }
            } catch (e: TimeoutCancellationException) {
                Log.e(TAG, "Find key operation timed out")
            }
        }

        return foundSecrets
    }
}