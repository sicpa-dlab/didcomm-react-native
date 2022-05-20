package com.sicpa.didcomm.reactnative

import com.facebook.react.bridge.*
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import org.json.JSONArray
import org.json.JSONObject

//Based on https://gist.github.com/viperwarp/2beb6bbefcc268dee7ad
object JsonUtils {
    fun createDefaultGson(): Gson {
        return GsonBuilder().create()
    }

    fun convertToJsonString(source: Any): String {
        return createDefaultGson().toJson(source)
    }

    fun <T> parseJson(json: String, resultClass: Class<T>): T {
        return createDefaultGson().fromJson(json, resultClass)
    }

    fun convertObjectToMap(obj: Any): WritableMap {
        return convertJsonToMap(
            JSONObject(convertToJsonString(obj))
        )
    }

    fun convertJsonToMap(jsonObject: JSONObject): WritableMap {
        val map: WritableMap = WritableNativeMap()

        val keysIterator = jsonObject.keys()
        for (key in keysIterator) {
            when (val value = jsonObject[key]) {
                is JSONObject -> {
                    map.putMap(key, convertJsonToMap(value))
                }
                is JSONArray -> {
                    map.putArray(key, convertJsonToArray(value))
                }
                is Boolean -> {
                    map.putBoolean(key, value)
                }
                is Int -> {
                    map.putInt(key, value)
                }
                is Double -> {
                    map.putDouble(key, value)
                }
                is String -> {
                    map.putString(key, value)
                }
                else -> {
                    map.putString(key, value.toString())
                }
            }
        }

        return map
    }

    fun convertJsonToArray(jsonArray: JSONArray): WritableArray {
        val array: WritableArray = WritableNativeArray()

        for (i in 0 until (jsonArray.length())) {
            when (val element = jsonArray.get(i)) {
                is JSONObject -> {
                    array.pushMap(convertJsonToMap(element))
                }
                is JSONArray -> {
                    array.pushArray(convertJsonToArray(element))
                }
                is Boolean -> {
                    array.pushBoolean(element)
                }
                is Int -> {
                    array.pushInt(element)
                }
                is Double -> {
                    array.pushDouble(element)
                }
                is String -> {
                    array.pushString(element)
                }
                else -> {
                    array.pushString(element.toString())
                }
            }
        }

        return array
    }

    fun convertMapToJson(readableMap: ReadableMap?): JSONObject {
        val jsonObject = JSONObject()

        val iterator = readableMap?.keySetIterator()
        while (iterator?.hasNextKey() == true) {
            val key = iterator.nextKey()
            val value = when (readableMap.getType(key)) {
                ReadableType.Null -> JSONObject.NULL
                ReadableType.Boolean -> readableMap.getBoolean(key)
                ReadableType.Number -> readableMap.getDouble(key)
                ReadableType.String -> readableMap.getString(key)
                ReadableType.Map -> convertMapToJson(readableMap.getMap(key))
                ReadableType.Array -> convertArrayToJson(readableMap.getArray(key))
            }
            jsonObject.put(key, value)
        }

        return jsonObject
    }

    fun convertArrayToJson(readableArray: ReadableArray?): JSONArray {
        val array = JSONArray()

        if (readableArray == null) {
            return array
        }

        for (index in 0 until (readableArray.size())) {
            val element = when (readableArray.getType(index)) {
                ReadableType.Null -> JSONObject.NULL
                ReadableType.Boolean -> readableArray.getBoolean(index)
                ReadableType.Number -> readableArray.getDouble(index)
                ReadableType.String -> readableArray.getString(index)
                ReadableType.Map -> convertMapToJson(readableArray.getMap(index))
                ReadableType.Array -> convertArrayToJson(readableArray.getArray(index))
            }
            array.put(element)
        }

        return array
    }
}
