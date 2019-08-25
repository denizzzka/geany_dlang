module geany_dlang.config_window;

import gtk.Widget: GtkWidget, GtkDialog;
import geany_d_binding.geany.plugins;
import geany_d_binding.geany.types;
import logger: nothrowLog;

extern(System) GtkWidget* configWindowDialog(GeanyPlugin* plugin, GtkDialog* dialog, gpointer pdata) nothrow
{
    import gtk.c.functions;
    import gtk.VBox;
    import gtk.Label;

    try
    {
        auto vbox = new VBox(false, 6);
        vbox.add(new Label("Capture SCN_CHARADDED editor event"));
        auto eventsExplanation = new Label(`Geany does not support capture of built-in autocompletion events. This plugin can use "char added" event to imitate of autocompletion events, but you will need to disable the built-in standard autocompletion in Geany preferences.`);
        eventsExplanation.setLineWrap(true);
        vbox.add(eventsExplanation);
        vbox.showAll;

        return cast(GtkWidget*) vbox.getVBoxStruct;
    }
    catch(Exception e)
    {
        nothrowLog!"fatal"(e.msg);

        return null;
    }

    /* Connect a callback for when the user clicks a dialog button */
    //~ g_signal_connect(dialog, "response", G_CALLBACK(on_configure_response), entry);
}
