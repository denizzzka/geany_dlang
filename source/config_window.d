module geany_dlang.config_window;

import gtk.Widget: GtkWidget, GtkDialog;
import geany_d_binding.geany.plugins;
import geany_d_binding.geany.types;
import logger: nothrowLog;
import geany_dlang.plugin: configFile;

extern(System) GtkWidget* configWindowDialog(GeanyPlugin* plugin, GtkDialog* dialogPtr, gpointer pdata) nothrow
{
    import geany_dlang.config;
    import gtk.Builder;
    import gtk.Box;
    import gtk.TreeView;
    import gtk.Dialog;
    import gobject.Signals;

    try
    {
        immutable guiDescr = import("preferences.glade");
        auto builder = new Builder();
        builder.addFromString(guiDescr);

        auto list = cast(ListStore) builder.getObject("dir_list_store");

        foreach(_; 0 .. 10)
            list.addPath("test path");

        auto box = cast(Box) builder.getObject("main_box");
        box.showAll;

        auto dialog = new Dialog(dialogPtr);
        Signals.connect(dialog, "response", &on_configure_response);

        return cast(GtkWidget*) box.getBoxStruct;
    }
    catch(Exception e)
    {
        nothrowLog!"fatal"(e);

        return null;
    }
}

void on_configure_response()
{
    nothrowLog!"trace"("Button pressed");

    import geany_dlang.plugin: configFile;
    configFile.saveConf();
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

import gtk.ListStore;

private enum
{
    COLUMN_ENABLED,
    COLUMN_PATH,
}

void addPath(ListStore list, string path)
{
    import gtk.TreeIter;

    //~ import gobject.Value;

    TreeIter iterator = list.createIter();
    //~ setValue(iterator, COLUMN_ENABLED, true);
    list.setValue(iterator, COLUMN_PATH, path);
}
