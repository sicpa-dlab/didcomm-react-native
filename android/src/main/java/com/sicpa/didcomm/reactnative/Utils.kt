package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.WritableMap
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.json.JSONObject

object Utils {
    fun convertObjectToMap(obj: Any): WritableMap {
        return ReactNativeJsonUtils.convertJsonToMap(
            JSONObject(
                Json.encodeToString(obj)
            )
        )
    }
}