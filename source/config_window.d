module geany_dlang.config_window;

import gtk.Widget: GtkWidget, GtkDialog;
import geany_d_binding.geany.plugins;
import geany_d_binding.geany.types;
import logger: nothrowLog;
import geany_dlang.plugin: configFile;

extern(System) GtkWidget* configWindowDialog(GeanyPlugin* plugin, GtkDialog* dialogPtr, gpointer pdata) nothrow
{
    import geany_dlang.config;
    import gtk.VBox;
    import gtk.CheckButton;
    import gtk.Label;
    import gtk.Dialog;
    import gobject.Signals;

    try
    {
        auto vbox = new VBox(false, 4);
        auto eventsExplanation = new Label(`Geany does not support capture of built-in autocompletion events. This plugin can use "char added" event to imitate of autocompletion events, but you will need to disable the built-in standard autocompletion in Geany preferences.`);
        eventsExplanation.setLineWrap(true);
        vbox.add(eventsExplanation);
        vbox.add(new CheckButton("Capture SCN_CHARADDED editor event"));

        vbox.add(new Label("Additional sources paths to scan:"));
        auto additionalSourcesList = new SrcDirsTreeView(new SrcDirsListStore);
        vbox.add(additionalSourcesList);

        vbox.showAll;

        auto dialog = new Dialog(dialogPtr);
        Signals.connect(dialog, "response", &on_configure_response);

        return cast(GtkWidget*) vbox.getVBoxStruct;
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

class SrcDirsListStore : ListStore
{
    this()
    {
        super([GType.BOOLEAN, GType.STRING]);
    }
}

import gtk.TreeView;

class SrcDirsTreeView : TreeView
{
    import gtk.TreeViewColumn;
    import gtk.CellRendererText;

    this(SrcDirsListStore list)
    {
        auto col = new TreeViewColumn;
        col.setTitle("Enabled");
        appendColumn(col);

        col = new TreeViewColumn;
        col.setTitle("Path");
        appendColumn(col);

        setModel(list);
    }
}
