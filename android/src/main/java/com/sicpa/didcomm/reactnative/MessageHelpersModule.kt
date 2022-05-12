package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.*
import org.didcommx.didcomm.DIDComm
import org.didcommx.didcomm.diddoc.DIDDocResolver
import org.didcommx.didcomm.message.Message
import org.didcommx.didcomm.model.PackEncryptedParams
import org.didcommx.didcomm.model.UnpackParams
import org.didcommx.didcomm.secret.SecretResolver
import org.json.JSONObject

class MessageHelpersModule(context: ReactApplicationContext) : ReactContextBaseJavaModule(context) {
    override fun getName() = "DIDCommMessageHelpers"

    @ReactMethod
    fun pack_encrypted(
        messageData: ReadableMap,
        to: String,
        from: String? = null,
        signFrom: String? = null,
        protectSender: Boolean = true,
        didDocResolver: DIDDocResolver,
        secretsResolver: SecretResolver
    ): WritableMap {
        val didComm = DIDComm(didDocResolver, secretsResolver)
        val message = Message.parse(messageData.toHashMap())

        var builder = PackEncryptedParams
            .builder(message, to)
            .forward(false)
            .protectSenderId(protectSender)
        builder = from?.let { builder.from(it) } ?: builder
        builder = signFrom?.let { builder.signFrom(it) } ?: builder

        val packResult = didComm.packEncrypted(builder.build())
        return ReactNativeJsonUtils.convertJsonToMap(JSONObject(packResult))
    }

    @ReactMethod
    fun unpack(packedMessage: String, didDocResolver: DIDDocResolver, secretsResolver: SecretResolver): WritableMap {
        val didComm = DIDComm(didDocResolver, secretsResolver)

        val unpackResult = didComm.unpack(UnpackParams.Builder(packedMessage).build())

        return ReactNativeJsonUtils.convertJsonToMap(JSONObject(unpackResult))
    }
}