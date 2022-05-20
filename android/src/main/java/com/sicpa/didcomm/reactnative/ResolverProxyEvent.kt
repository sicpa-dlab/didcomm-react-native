package com.sicpa.didcomm.reactnative

sealed class ResolverProxyEvent(val type: String)

class ResolveDid(val did: String) : ResolverProxyEvent("resolve-did")
class FindKey(val kid: String) : ResolverProxyEvent("find-key")
class FindKeys(val kids: List<String>) : ResolverProxyEvent("find-keys")