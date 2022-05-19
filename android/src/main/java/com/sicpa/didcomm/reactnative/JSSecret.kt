package com.sicpa.didcomm.reactnative

import com.google.gson.GsonBuilder
import org.didcommx.didcomm.common.VerificationMaterial
import org.didcommx.didcomm.common.VerificationMaterialFormat
import org.didcommx.didcomm.common.VerificationMethodType
import org.didcommx.didcomm.secret.Secret

data class JSSecretMaterial(val format: String, val value: Any)

data class JSSecret(val id: String, val type: String, val secret_material: JSSecretMaterial) {
    fun toJVMSecret(): Secret {
        val verificationMethodType = when (type) {
            "JsonWebKey2020" -> VerificationMethodType.JSON_WEB_KEY_2020
            "X25519KeyAgreementKey2019" -> VerificationMethodType.X25519_KEY_AGREEMENT_KEY_2019
            "Ed25519VerificationKey2018" -> VerificationMethodType.ED25519_VERIFICATION_KEY_2018
            "EcdsaSecp256k1VerificationKey2019" -> VerificationMethodType.OTHER
            else -> VerificationMethodType.OTHER
        }

        val verificationMaterialFormat = when (secret_material.format) {
            "JWK" -> VerificationMaterialFormat.JWK
            "Multibase" -> VerificationMaterialFormat.MULTIBASE
            "Base58" -> VerificationMaterialFormat.BASE58
            else -> VerificationMaterialFormat.OTHER
        }

        return Secret(
            id,
            verificationMethodType,
            VerificationMaterial(
                verificationMaterialFormat,
                JsonUtils.toJsonString(secret_material.value)
            )
        )
    }
}