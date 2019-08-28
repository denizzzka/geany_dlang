module geany_dlang.config_window;

import gtk.Widget: GtkWidget, GtkDialog;
import geany_d_binding.geany.plugins;
import geany_d_binding.geany.types;
import logger: nothrowLog;
import geany_dlang.plugin: configFile;
import gtk.Builder;

extern(System) GtkWidget* configWindowDialog(GeanyPlugin* plugin, GtkDialog* dialogPtr, gpointer pdata) nothrow
{
    import geany_dlang.config;
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

        fillPrefsFromConfig(builder);

        auto box = cast(Box) builder.getObject("main_box");
        box.showAll;

        void on_configure_response(int response, Dialog d)
        {
            const r = cast(GtkResponseType) response;

            if (r == GtkResponseType.OK || r == GtkResponseType.APPLY)
            {
                nothrowLog!"trace"("Save config");

                savePrefsToConfig(builder);
                configFile.saveConf();
            }
        }

        auto dialog = new Dialog(dialogPtr);
        dialog.addOnResponse(&on_configure_response);

        return cast(GtkWidget*) box.getBoxStruct;
    }
    catch(Exception e)
    {
        nothrowLog!"fatal"(e);

        return null;
    }
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

import gtk.ToggleButton;

private auto getCharAddCheckBox(Builder b)
{
    return cast(ToggleButton) b.getObject("capture_charadded_checkbox");
}

private void fillPrefsFromConfig(Builder b)
{
    b.getCharAddCheckBox.setActive = configFile.config.useCharAddEvent;
}

private void savePrefsToConfig(Builder b)
{
    configFile.config.useCharAddEvent = b.getCharAddCheckBox.getActive;
}
