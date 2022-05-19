package com.sicpa.didcomm.reactnative

import com.google.gson.GsonBuilder
import org.didcommx.didcomm.common.VerificationMaterial
import org.didcommx.didcomm.common.VerificationMaterialFormat
import org.didcommx.didcomm.common.VerificationMethodType
import org.didcommx.didcomm.diddoc.DIDCommService
import org.didcommx.didcomm.diddoc.DIDDoc
import org.didcommx.didcomm.diddoc.VerificationMethod


data class JSService(val id: String, val kind: JSServiceKind)
data class JSServiceKind(val DIDCommMessaging: JSDIDCommMessagingService)
data class JSDIDCommMessagingService(
    val service_endpoint: String,
    val accept: List<String>,
    val route_keys: List<String>
)

data class JSVerificationMethod(
    val id: String,
    val type: String,
    val controller: String,
    val verification_material: JSVerificationMaterial
)

data class JSVerificationMaterial(val format: String, val value: Any)

data class JSDIDDoc(
    val did: String,
    val key_agreements: List<String>,
    val authentications: List<String>,
    val verification_methods: List<JSVerificationMethod>,
    val services: List<JSService>
) {
    fun toDIDDoc(): DIDDoc {
        val verificationMethods = verification_methods.map {
            val verificationMethodType = when (it.type) {
                "JsonWebKey2020" -> VerificationMethodType.JSON_WEB_KEY_2020
                "X25519KeyAgreementKey2019" -> VerificationMethodType.X25519_KEY_AGREEMENT_KEY_2019
                "Ed25519VerificationKey2018" -> VerificationMethodType.ED25519_VERIFICATION_KEY_2018
                "EcdsaSecp256k1VerificationKey2019" -> VerificationMethodType.OTHER
                else -> VerificationMethodType.OTHER
            }

            val verificationMaterialFormat = when (it.verification_material.format) {
                "JWK" -> VerificationMaterialFormat.JWK
                "Multibase" -> VerificationMaterialFormat.MULTIBASE
                "Base58" -> VerificationMaterialFormat.BASE58
                else -> VerificationMaterialFormat.OTHER
            }

            val verificationMaterial = VerificationMaterial(
                verificationMaterialFormat,
                GsonBuilder().create().toJson(it.verification_material.value)
            )

            VerificationMethod(it.id, verificationMethodType, verificationMaterial, it.controller)
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
