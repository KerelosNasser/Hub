package com.example.farahs_hub

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import android.util.Log
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class FarahsHubWidgetProvider : HomeWidgetProvider() {
    companion object {
        private const val TAG = "FarahsHubWidget"
        private const val DEFAULT_TITLE = "Farah's Hub"
        private const val DEFAULT_MESSAGE = "Tap to open app"
    }
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        try {
            Log.d(TAG, "Widget update requested for ${appWidgetIds.size} widgets")
            
            appWidgetIds.forEach { widgetId ->
                updateSingleWidget(context, appWidgetManager, widgetId, widgetData)
            }
            
            Log.d(TAG, "Widget update completed successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget", e)
        }
    }
    
    private fun updateSingleWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: SharedPreferences
    ) {
        try {
            val views = RemoteViews(context.packageName, R.layout.farahs_hub_widget)
            
            // Get data from SharedPreferences with defaults
            val title = widgetData.getString("title_key", DEFAULT_TITLE) ?: DEFAULT_TITLE
            
            // Format current date if not provided
            val currentDate = java.text.SimpleDateFormat("MMMM d, yyyy", java.util.Locale.US)
                .format(java.util.Date())
            val date = widgetData.getString("date_key", currentDate) ?: currentDate
            
            val message = widgetData.getString("message_key", DEFAULT_MESSAGE) ?: DEFAULT_MESSAGE

            // Update the UI with the data
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_date, date)
            views.setTextViewText(R.id.widget_message, message)

            // Set up flags for PendingIntent - always use FLAG_IMMUTABLE in 2025
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            
            // Set click listener for the widget title (opens the app)
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

            // Set click listener for the view notes button
            val viewNotesIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("farahshub://notes")
            )
            views.setOnClickPendingIntent(R.id.widget_view_notes_btn, viewNotesIntent)
            
            // Set click listener for the add note button
            val addNoteIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("farahshub://notes/add")
            )
            views.setOnClickPendingIntent(R.id.widget_add_note_btn, addNoteIntent)

            // Update the widget
            appWidgetManager.updateAppWidget(widgetId, views)
            Log.d(TAG, "Widget $widgetId updated successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget $widgetId", e)
        }
    }
    
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "Widget provider enabled")
    }
    
    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d(TAG, "Widget provider disabled")
    }
}
