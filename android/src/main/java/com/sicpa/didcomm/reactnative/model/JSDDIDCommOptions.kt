package com.sicpa.didcomm.reactnative.model

data class JSPackEncryptedOptions(
    val protect_sender: Boolean?,
    val forward: Boolean?,
    val forward_headers: Map<String, String>?,
    val messaging_service: String?,
    val enc_alg_auth: String?,
    val enc_alg_anon: String?
)

data class JSUnpackOptions(
    val expect_decrypt_by_all_keys: Boolean?,
    val unwrap_re_wrapping_forward: Boolean?
)