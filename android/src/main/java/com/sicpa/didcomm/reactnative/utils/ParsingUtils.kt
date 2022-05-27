package com.sicpa.didcomm.reactnative.utils

import org.didcommx.didcomm.common.AnonCryptAlg
import org.didcommx.didcomm.common.VerificationMaterialFormat
import org.didcommx.didcomm.common.VerificationMethodType

fun parseVerificationMethodType(type: String): VerificationMethodType {
    return when (type) {
        "JsonWebKey2020" -> VerificationMethodType.JSON_WEB_KEY_2020
        "X25519KeyAgreementKey2019" -> VerificationMethodType.X25519_KEY_AGREEMENT_KEY_2019
        "Ed25519VerificationKey2018" -> VerificationMethodType.ED25519_VERIFICATION_KEY_2018
        "EcdsaSecp256k1VerificationKey2019" -> VerificationMethodType.OTHER
        else -> VerificationMethodType.OTHER
    }
}

fun parseVerificationMaterialFormat(format: String): VerificationMaterialFormat {
    return when (format) {
        "JWK" -> VerificationMaterialFormat.JWK
        "Multibase" -> VerificationMaterialFormat.MULTIBASE
        "Base58" -> VerificationMaterialFormat.BASE58
        else -> VerificationMaterialFormat.OTHER
    }
}

fun parseAnonCryptAlg(alg: String): AnonCryptAlg {
    return when(alg) {
        "A256cbcHs512EcdhEsA256kw" -> AnonCryptAlg.A256CBC_HS512_ECDH_ES_A256KW
        "Xc20pEcdhEsA256kw" -> AnonCryptAlg.XC20P_ECDH_ES_A256KW
        "A256gcmEcdhEsA256kw" -> AnonCryptAlg.A256GCM_ECDH_ES_A256KW
        else -> AnonCryptAlg.XC20P_ECDH_ES_A256KW
    }
}