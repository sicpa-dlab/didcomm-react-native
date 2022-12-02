package com.sicpa.didcomm.reactnative.model

import com.sicpa.didcomm.reactnative.utils.JsonUtils
import com.sicpa.didcomm.reactnative.utils.parseVerificationMaterialFormat
import com.sicpa.didcomm.reactnative.utils.parseVerificationMethodType
import org.didcommx.didcomm.common.VerificationMaterial
import org.didcommx.didcomm.diddoc.DIDCommService
import org.didcommx.didcomm.diddoc.DIDDoc
import org.didcommx.didcomm.diddoc.VerificationMethod

data class JSDIDDoc(
    val did: String,
    val key_agreements: List<String>,
    val authentications: List<String>,
    val verification_methods: List<JSVerificationMethod>,
    val services: List<JSDIDCommService>
) {
    fun toDIDDoc(): DIDDoc {
        val verificationMethods = verification_methods.map {
            val verificationMaterialValueStr = (it.verification_material.value as? String)
                ?: JsonUtils.convertToJsonString(it.verification_material.value)

            val verificationMaterial = VerificationMaterial(
                parseVerificationMaterialFormat(it.verification_material.format),
                verificationMaterialValueStr,
            )

            VerificationMethod(
                it.id,
                parseVerificationMethodType(it.type),
                verificationMaterial,
                it.controller
            )
        }

        val services = services.map {
            val service = it.kind.DIDCommMessaging
            DIDCommService(it.id, service.service_endpoint, service.routing_keys, service.accept)
        }

        return DIDDoc(
            did,
            key_agreements,
            authentications,
            verificationMethods,
            services
        )
    }
}
