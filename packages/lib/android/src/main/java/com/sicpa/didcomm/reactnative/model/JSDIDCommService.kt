package com.sicpa.didcomm.reactnative.model

data class JSDIDCommService(val id: String, val kind: JSDIDCommServiceKind)
//TODO: Support 'Other' service kind variant: https://github.com/sicpa-dlab/didcomm-rust/blob/main/wasm/src/did/did_doc.rs#L98
data class JSDIDCommServiceKind(val DIDCommMessaging: JSDIDCommMessagingService)
data class JSDIDCommMessagingService(
    val service_endpoint: String,
    val accept: List<String>,
    val route_keys: List<String>
)