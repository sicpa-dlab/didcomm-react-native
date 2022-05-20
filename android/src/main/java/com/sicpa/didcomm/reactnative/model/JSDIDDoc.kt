package com.sicpa.didcomm.reactnative.model

import com.sicpa.didcomm.reactnative.JsonUtils
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
            val verificationMaterial = VerificationMaterial(
                parseVerificationMaterialFormat(it.verification_material.format),
                JsonUtils.convertToJsonString(it.verification_material.value)
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
            DIDCommService(it.id, service.service_endpoint, service.route_keys, service.accept)
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
