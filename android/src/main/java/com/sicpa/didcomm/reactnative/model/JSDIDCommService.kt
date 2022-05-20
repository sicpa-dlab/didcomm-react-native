package com.sicpa.didcomm.reactnative.model

data class JSDIDCommService(val id: String, val kind: JSServiceKind)
data class JSServiceKind(val DIDCommMessaging: JSDIDCommMessagingService)
data class JSDIDCommMessagingService(
    val service_endpoint: String,
    val accept: List<String>,
    val route_keys: List<String>
)