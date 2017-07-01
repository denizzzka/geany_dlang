version(IntegrationTest){} else:

import geany_plugin_d_api;
import dcd_wrapper;
import logger;

enum serverStart = "dub run dcd --build=release --config=server";
private GeanyPlugin* geany_plugin;
private DcdWrapper wrapper;

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
    import geany_plugin_d_api.document;
    import geany_plugin_d_api.filetypes;
    import common.messages;
    import geany_plugin_d_api.sciwrappers;

    GeanyDocument* doc = document_get_current();

    if(doc != null && doc.file_type.id == GeanyFiletypeID.GEANY_FILETYPES_D)
    {
        auto sci = doc.editor.sci;
        const textLen = sci.sci_get_length;
        char* textBuff = sci.sci_get_contents(-1);
        scope(exit) g_free(textBuff);

        AutocompleteRequest req;
        req.kind = RequestKind.autocomplete;
        req.cursorPosition = sci.sci_get_current_position;
        req.sourceCode = cast(ubyte[]) textBuff[0 .. textLen+1];

        auto ret = wrapper.doRequest(req);

        //TODO: use ret
    }
}

gboolean initPlugin(GeanyPlugin *plugin, gpointer pdata)
{
    geany_plugin = plugin;

    try
        wrapper = new DcdWrapper();
    catch(Exception e)
    {
        nothrowLog!"fatal"(e.msg);

        return false;
    }

    return true;
}

void cleanupPlugin(GeanyPlugin *plugin, gpointer pdata)
{
    try
        destroy(wrapper);
    catch(Exception e)
        nothrowLog!"fatal"(e.msg);
}

void geany_load_module(GeanyPlugin *plugin)
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
        nothrowLog!"fatal"(e.msg);
}
