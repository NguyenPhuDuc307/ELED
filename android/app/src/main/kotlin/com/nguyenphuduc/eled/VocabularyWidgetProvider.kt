package com.nguyenphuduc.eled

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

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
                val word = widgetData.getString("word", "ELED VOCAB")
                val translation = widgetData.getString("translation", "WAITING FOR SCHEDULE...")
                val ipa = widgetData.getString("ipa", "")

                setTextViewText(R.id.widget_word, word)
                setTextViewText(R.id.widget_translation, translation)
                setTextViewText(R.id.widget_ipa, ipa)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
