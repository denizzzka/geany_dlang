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

import gtk.ToggleButton;

private auto getCharAddCheckBox(Builder b)
{
    return cast(ToggleButton) b.getObject("capture_charadded_checkbox");
}

private auto getPathsList(Builder b)
{
    return cast(ListStore) b.getObject("dir_list_store");
}

private void fillPrefsFromConfig(Builder b)
{
    b.getCharAddCheckBox.setActive = configFile.config.useCharAddEvent;

    auto list = b.getPathsList;
    list.clear;

    foreach(path; configFile.config.additionalPaths)
    {
        auto iterator = list.createIter();
        list.setValue(iterator, COLUMN_PATH, path);
    }
}

private void savePrefsToConfig(Builder b)
{
    configFile.config.useCharAddEvent = b.getCharAddCheckBox.getActive;
}
