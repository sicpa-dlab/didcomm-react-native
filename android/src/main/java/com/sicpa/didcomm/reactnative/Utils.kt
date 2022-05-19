package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.WritableMap
import com.google.gson.GsonBuilder
import org.json.JSONObject

object Utils {
    fun convertObjectToMap(obj: Any): WritableMap {
        return ReactNativeJsonUtils.convertJsonToMap(
            JSONObject(
                GsonBuilder().create().toJson(obj)
            )
        )
    }

    fun <T>parseJson(json: String, resultClass: Class<T>): T {
        return GsonBuilder().create().fromJson(json, resultClass)
    }

}