package com.nguyenphuduc.eled

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import android.view.View

class VocabularyWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.vocabulary_widget).apply {
                // Read from SharedPreferences matching Flutter's home_widget keys
                val word = widgetData.getString("word", "ELED VOCAB") ?: "ELED VOCAB"
                val translation = widgetData.getString("translation", "WAITING FOR SCHEDULE...") ?: "WAITING FOR SCHEDULE..."
                val ipa = widgetData.getString("ipa", "") ?: ""
                val pos = widgetData.getString("pos", "") ?: ""
                val levels = widgetData.getString("levels", "") ?: ""
                val topic = widgetData.getString("topic", "") ?: ""

                setTextViewText(R.id.widget_word, word)
                setTextViewText(R.id.widget_translation, translation)
                
                val ipaStr = if (ipa.isEmpty()) "" else " $ipa"
                val posStr = if (pos.isEmpty()) "" else "${pos.uppercase()} |"
                val posIpa = "$posStr$ipaStr".trim()
                
                if (posIpa.isEmpty()) {
                    setViewVisibility(R.id.widget_pos_ipa, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_pos_ipa, View.VISIBLE)
                    setTextViewText(R.id.widget_pos_ipa, posIpa)
                }
                
                if (levels.isEmpty()) {
                    setViewVisibility(R.id.widget_levels_border, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_levels_border, View.VISIBLE)
                    setTextViewText(R.id.widget_levels, levels.uppercase())
                }

                if (topic.isEmpty()) {
                    setViewVisibility(R.id.widget_topic_border, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_topic_border, View.VISIBLE)
                    setTextViewText(R.id.widget_topic, topic.uppercase())
                }

                val encodedWord = android.net.Uri.encode(word)
                val encodedTopic = android.net.Uri.encode(topic)
                val pendingIntent = es.antonborri.home_widget.HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    android.net.Uri.parse("eled://vocabWidget?payload=$encodedWord|$encodedTopic")
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
