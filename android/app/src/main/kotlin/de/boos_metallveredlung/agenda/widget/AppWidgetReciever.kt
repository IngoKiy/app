package de.boos_metallveredlung.agenda.widget


import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class AppWidgetReciever : HomeWidgetGlanceWidgetReceiver<AppWidget>() {
    override val glanceAppWidget = AppWidget()
}
