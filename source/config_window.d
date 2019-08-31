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
    import gtk.CellRendererText;
    import gtk.Dialog;
    import gobject.Signals;

    nothrowLog!"trace"(__FUNCTION__);

    try
    {
        immutable guiDescr = import("preferences.glade");
        auto builder = new Builder();
        builder.addFromString(guiDescr);

        fillPrefsFromConfig(builder);

        auto pathCellRenderer = cast(CellRendererText) builder.getObject("path_cell_renderer");
        pathCellRenderer.addOnEdited(
            (string position, string val, CellRendererText cell)
            {
                import gtk.TreePath;
                import gtk.TreeIter;

                auto path = new TreePath(position);
                auto list = builder.getPathsList;
                auto iter = new TreeIter(list, path);
                list.setValue(iter, COLUMN_PATH, val);
            }
        );

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

                import geany_dlang.plugin;
                wrapper.substituteDcdPaths(configFile.config.additionalPaths);
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

    //~ auto list = b.getPathsList;
    //~ auto iterator = list.createIter();

    //~ configFile.config.additionalPaths.length = 0;

    //~ configFile.config.additionalPaths ~= iterator.getValueString(COLUMN_PATH);

    //~ foreach(row; list)
    //~ {
        //~ list.setValue(iterator, COLUMN_PATH, path);
    //~ }
}
