package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import org.didcommx.didcomm.DIDComm
import org.didcommx.didcomm.diddoc.DIDDocResolver
import org.didcommx.didcomm.message.Message
import org.didcommx.didcomm.model.PackEncryptedParams
import org.didcommx.didcomm.model.PackEncryptedResult
import org.didcommx.didcomm.model.UnpackParams
import org.didcommx.didcomm.model.UnpackResult
import org.didcommx.didcomm.secret.SecretResolver

class MessageHelpersModule(context: ReactApplicationContext) : ReactContextBaseJavaModule(context) {
    override fun getName() = "DIDCommMessageHelpers"

    @ReactMethod
    fun pack_encrypted(
        message: Message,
        to: String,
        from: String? = null,
        signFrom: String? = null,
        protectSender: Boolean = true,
        didDocResolver: DIDDocResolver,
        secretsResolver: SecretResolver
    ): PackEncryptedResult {
        val didComm = DIDComm(didDocResolver, secretsResolver)

        var builder = PackEncryptedParams
            .builder(message, to)
            .forward(false)
            .protectSenderId(protectSender)
        builder = from?.let { builder.from(it) } ?: builder
        builder = signFrom?.let { builder.signFrom(it) } ?: builder

        val params = builder.build()
        return didComm.packEncrypted(params)
    }

    @ReactMethod
    fun unpack(packedMessage: String,didDocResolver: DIDDocResolver, secretsResolver: SecretResolver): UnpackResult {
        val didComm = DIDComm(didDocResolver, secretsResolver)

        val result = didComm.unpack(UnpackParams.Builder(packedMessage).build())

        return UnpackResult(result.message, result.metadata)
    }
}