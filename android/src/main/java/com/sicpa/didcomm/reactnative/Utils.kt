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

    inline fun <reified TSource, reified TResult>mapObject(obj: TSource): TResult {
        val gson = GsonBuilder().create()
        val sourceJson = gson.toJsonTree(obj, TSource::class.java)
        return gson.fromJson(sourceJson, TResult::class.java)
    }
}