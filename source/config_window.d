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

    /* example configuration dialog */
    //~ GtkVBox* vboxPtr = gtk_vbox_new(false, 6);
    try
    {
        auto vbox = new VBox(false, 6);
        vbox.add(new Label("Capture SCN_CHARADDED editor event"));
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
