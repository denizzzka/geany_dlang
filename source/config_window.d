module geany_dlang.config_window;

import gtk.Widget: GtkWidget, GtkDialog;
import geany_d_binding.geany.plugins;
import geany_d_binding.geany.types;
import logger: nothrowLog;

extern(System) GtkWidget* configWindowDialog(GeanyPlugin* plugin, GtkDialog* dialogPtr, gpointer pdata) nothrow
{
    import gtk.VBox;
    import gtk.Label;
    import gtk.Dialog;
    import gobject.Signals;

    try
    {
        auto vbox = new VBox(false, 6);
        vbox.add(new Label("Capture SCN_CHARADDED editor event"));
        auto eventsExplanation = new Label(`Geany does not support capture of built-in autocompletion events. This plugin can use "char added" event to imitate of autocompletion events, but you will need to disable the built-in standard autocompletion in Geany preferences.`);
        eventsExplanation.setLineWrap(true);
        vbox.add(eventsExplanation);
        vbox.showAll;

        auto dialog = new Dialog(dialogPtr);
        Signals.connect(dialog, "response", &on_configure_response);

        return cast(GtkWidget*) vbox.getVBoxStruct;
    }
    catch(Exception e)
    {
        nothrowLog!"fatal"(e.msg);

        return null;
    }
}

void on_configure_response()
{
    nothrowLog!"trace"("Button pressed");
    //~ /* catch OK or Apply clicked */
    //~ if (response == GTK_RESPONSE_OK || response == GTK_RESPONSE_APPLY)
    //~ {
        //~ /* We only have one pref here, but for more you would use a struct for user_data */
        //~ GtkWidget *entry = GTK_WIDGET(user_data);

        //~ g_free(welcome_text);
        //~ welcome_text = g_strdup(gtk_entry_get_text(GTK_ENTRY(entry)));
        //~ /* maybe the plugin should write here the settings into a file
         //~ * (e.g. using GLib's GKeyFile API)
         //~ * all plugin specific files should be created in:
         //~ * geany->app->configdir G_DIR_SEPARATOR_S plugins G_DIR_SEPARATOR_S pluginname G_DIR_SEPARATOR_S
         //~ * e.g. this could be: ~/.config/geany/plugins/Demo/, please use geany->app->configdir */
    //~ }
}
