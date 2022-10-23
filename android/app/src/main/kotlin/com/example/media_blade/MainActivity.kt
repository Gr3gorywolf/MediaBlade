package com.gr3apps.media_blade

import android.content.Intent
import android.widget.Toast
import androidx.annotation.NonNull
import com.fasterxml.jackson.databind.ObjectMapper
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLRequest
import com.yausername.youtubedl_android.mapper.VideoInfo
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import android.webkit.URLUtil
import java.util.ArrayList
import java.util.regex.Pattern

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ytdl"
    private var IsInitialized = false;
    private var IntentUrl:String? = null;
    private var engine: FlutterEngine? = null;

    private fun extractUrls(text: String): List<String> {
        val containedUrls: MutableList<String> = ArrayList()
        val urlRegex =
                "((https?|ftp|gopher|telnet|file):((//)|(\\\\))+[\\w\\d:#@%/;$()~_?+-=\\\\.&]*)"
        val pattern = Pattern.compile(urlRegex, Pattern.CASE_INSENSITIVE)
        val urlMatcher = pattern.matcher(text)
        while (urlMatcher.find()) {
            containedUrls.add(text.substring(urlMatcher.start(0), urlMatcher.end(0)))
        }
        return containedUrls
    }

    private fun cleanUrl(url: String): String {
        val extractedUrls = extractUrls(url)
        for (link in extractedUrls) {
            return link
        }
        return url
    }

    private fun handleIntent(intent: Intent) {

        if (Intent.ACTION_SEND == intent.action) {
            intent.getStringExtra(Intent.EXTRA_TEXT)?.let {
                val cleanUrl = cleanUrl(it)
                if (!URLUtil.isValidUrl(cleanUrl)) {
                    Toast.makeText(applicationContext, "Invalid URL", Toast.LENGTH_SHORT)
                            .show()
                    return
                }
                IntentUrl = cleanUrl
            }
        }
    }
    private  fun sendNewIntent(){
        val eng = this.engine;
        if(this.IntentUrl != null && eng != null){
            MethodChannel(eng.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("newIntent",IntentUrl)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent);
        sendNewIntent();
    }




    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.engine = flutterEngine;

        handleIntent(this.intent);
        sendNewIntent();

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            if (call.method == "getVideoResults") {
                GlobalScope.launch {
                    try {
                        withContext(Dispatchers.IO) {
                            val url = call.argument<String>("url")
                            Log.i("YTDL", "RESULTS_FETCHING")
                            val streamInfo: VideoInfo = YoutubeDL.getInstance().getInfo(url)
                            val title = streamInfo.getTitle()
                            Log.i("YTDL", "RESULTS_FETCHED")
                            val mapper = ObjectMapper()
                            result.success(mapper.writeValueAsString(streamInfo))
                        }
                    } catch (e: Exception) {
                        Log.i("YTDL", "RESULTS_FETCHING_FAILED")
                        result.error("ERROR", e.message, null)
                    }
                }
            } else if (call.method == "getIntentUrl") {
                result.success(this.IntentUrl);
                this.IntentUrl = null;
            } else {
                result.notImplemented()
            }
        }

        GlobalScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    Log.i("YTDL", "INITIALIZING")
                    YoutubeDL.getInstance().init(applicationContext)
                    Log.i("YTDL", "INITIALIZED")
                }
            } catch (e: Exception) {
                val msg = e.message;
                Log.i("YTDL", "initialization failed $msg")
                Toast.makeText(applicationContext, "initialization failed", Toast.LENGTH_LONG).show()
            }
        }
    }
}
