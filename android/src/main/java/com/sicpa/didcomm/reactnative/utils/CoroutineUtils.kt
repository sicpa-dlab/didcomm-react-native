package com.sicpa.didcomm.reactnative.utils

import android.util.Log
import kotlinx.coroutines.Job
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout

private const val DEFAULT_JOB_TIMEOUT: Long = 3000

fun runBlockingWithTimeout(job: Job, tag: String, timeoutMillis: Long = DEFAULT_JOB_TIMEOUT) {
    runBlocking {
        try {
            withTimeout(timeoutMillis) {
                job.join()
            }
        } catch (e: TimeoutCancellationException) {
            Log.e(tag, "Operation timed out")
        }
    }
}