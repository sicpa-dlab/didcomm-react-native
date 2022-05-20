package com.sicpa.didcomm.reactnative.model

data class JSVerificationMethod(
    val id: String,
    val type: String,
    val controller: String,
    val verification_material: JSVerificationMaterial
)
data class JSVerificationMaterial(val format: String, val value: Any)