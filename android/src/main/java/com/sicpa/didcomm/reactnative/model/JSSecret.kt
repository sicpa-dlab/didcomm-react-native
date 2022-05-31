package com.sicpa.didcomm.reactnative.model

import com.sicpa.didcomm.reactnative.utils.JsonUtils
import com.sicpa.didcomm.reactnative.utils.parseVerificationMaterialFormat
import com.sicpa.didcomm.reactnative.utils.parseVerificationMethodType
import org.didcommx.didcomm.common.VerificationMaterial
import org.didcommx.didcomm.secret.Secret

data class JSSecret(val id: String, val type: String, val secret_material: JSSecretMaterial) {
    fun toSecret(): Secret {
        val secretMaterialValueStr = (secret_material.value as? String)
            ?: JsonUtils.convertToJsonString(secret_material.value)

        return Secret(
            id,
            parseVerificationMethodType(type),
            VerificationMaterial(
                parseVerificationMaterialFormat(secret_material.format),
                secretMaterialValueStr,
            )
        )
    }
}

data class JSSecretMaterial(val format: String, val value: Any)