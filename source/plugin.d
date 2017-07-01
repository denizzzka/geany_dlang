version(IntegrationTest){} else:

import geany_plugin_d_api;
import dcd_wrapper;

enum serverStart = "dub run dcd --build=release --config=server";
private GeanyPlugin* geany_plugin;
DcdWrapper wrapper;

void init_keybindings()
{
    import geany_plugin_d_api.keybindings;
    import geany_plugin_d_api.pluginutils;
    import gdk.Gdk: GdkModifierType;
    import gtk.Widget: GtkWidget;

    GeanyKeyGroup* key_group = plugin_set_key_group(geany_plugin, "dlang_keys", 1, null);

    keybindings_set_item(
            key_group,
            0,
            &force_completion,
            0,
            cast(GdkModifierType) 0,
            "exec",
            "complete",
            cast(GtkWidget*) null
        );
}

extern(System) nothrow:

void force_completion(guint key_id)
{
}

gboolean initPlugin(GeanyPlugin *plugin, gpointer pdata) nothrow
{
    geany_plugin = plugin;

    try
        wrapper = new DcdWrapper();
    catch(Exception e)
    {
        nothrowFatal(e.msg);

        return false;
    }

    return true;
}

void cleanupPlugin(GeanyPlugin *plugin, gpointer pdata) nothrow
{
    try
        destroy(wrapper);
    catch(Exception e)
        nothrowFatal(e.msg);
}

void geany_load_module(GeanyPlugin *plugin) nothrow
{
    plugin.funcs._init = &initPlugin;
    plugin.funcs.cleanup = &cleanupPlugin;

    plugin.info.name = "D language";
    plugin.info.description = "Adds D language support";
    plugin.info._version = "0.0.1";
    plugin.info.author = "Denis Feklushkin <denis.feklushkin@gmail.com>";

    try
        GEANY_PLUGIN_REGISTER(plugin, 225);
    catch(Exception e)
        nothrowFatal(e.msg);
}

private void nothrowFatal
(
    int line = __LINE__,
    string file = __FILE__,
    string funcName = __FUNCTION__,
    string prettyFuncName = __PRETTY_FUNCTION__,
    string moduleName = __MODULE__,
    A...
)
(lazy string msg) nothrow
{
    import std.experimental.logger;

    try
        fatal!(line, file, funcName, prettyFuncName, moduleName)(msg);
    catch(Exception e)
    {
        // TODO: pass error to unthrowable geany logger
    }
}
