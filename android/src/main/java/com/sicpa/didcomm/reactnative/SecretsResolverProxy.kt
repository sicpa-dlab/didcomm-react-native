package com.sicpa.didcomm.reactnative

import android.util.Log
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
                foundSecret = resolveKeyFromProxy(kid)

                // Additional logs and retry logic for debugging. Related to #937
                if (foundSecret?.kid != kid) {
                    Log.e(
                        TAG,
                        "Got invalid result from proxy. Requested KID: ${kid}, Result KID: ${foundSecret?.kid}. Retrying..."
                    )
                    foundSecret = resolveKeyFromProxy(kid)
                    if (foundSecret?.kid != kid) Log.e(
                        TAG,
                        "Got invalid result on retry. Requested KID: ${kid}, Result KID: ${foundSecret?.kid}"
                    )
                }
            }
        }

        runBlockingWithTimeout(findKeyJob, "${TAG}.findKey")

        return Optional.ofNullable(foundSecret)
    }

    override fun findKeys(kids: List<String>): Set<String> {
        var foundSecrets: Set<String> = emptySet()

        val findKeysJob = scope.launch {
            findKeysMutex.withLock {
                foundSecrets = resolveKeysFromProxy(kids)

                // Additional logs and retry logic for debugging. Related to #937
                if (foundSecrets.any { !kids.contains(it) }) {
                    Log.e(
                        TAG,
                        "Got invalid result from proxy. Requested KIDs: ${kids.joinToString()}, Result DID: ${foundSecrets.joinToString()}. Retrying..."
                    )
                    foundSecrets = resolveKeysFromProxy(kids)
                    if (foundSecrets.any { !kids.contains(it) }) Log.e(
                        TAG,
                        "Got invalid result on retry. Requested KID: ${kids.joinToString()}, Result KID: ${foundSecrets.joinToString()}"
                    )
                }
            }
        }

        runBlockingWithTimeout(findKeysJob, "${TAG}.findKeys")

        return foundSecrets
    }

    private suspend fun resolveKeyFromProxy(kid: String): Secret? {
        resolversProxyModule.sendEvent(FindKey(kid), resolversId)
        return foundSecretChannel.receive()
    }

    private suspend fun resolveKeysFromProxy(kids: List<String>): Set<String> {
        resolversProxyModule.sendEvent(FindKeys(kids), resolversId)
        return foundSecretIdsChannel.receive()
    }
}