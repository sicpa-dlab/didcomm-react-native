package com.sicpa.didcomm.reactnative.model

import com.sicpa.didcomm.reactnative.JsonUtils
import org.didcommx.didcomm.common.VerificationMaterial
import org.didcommx.didcomm.secret.Secret

data class JSSecret(val id: String, val type: String, val secret_material: JSSecretMaterial) {
    fun toSecret(): Secret {
        return Secret(
            id,
            parseVerificationMethodType(type),
            VerificationMaterial(
                parseVerificationMaterialFormat(secret_material.format),
                JsonUtils.convertToJsonString(secret_material.value)
            )
        )
    }
}

data class JSSecretMaterial(val format: String, val value: Any)