version(IntegrationTest){} else:

import geany_d_binding;
import dcd_wrapper;
import logger;

enum serverStart = "dub run dcd --build=release --config=server";
private GeanyPlugin* geany_plugin;
private DcdWrapper wrapper;

void init_keybindings()
{
    import geany_d_binding.pluginutils;
    import geany_d_binding.keybindings;
    import gdk.Gdk: GdkModifierType;
    import gtk.Widget: GtkWidget;

    const gsize COUNT_KB = 1;

    GeanyKeyGroup* key_group = plugin_set_key_group(
            geany_plugin,
            "dlang_keys",
            COUNT_KB,
            null // GeanyKeyGroupCallback
        );

    const gint KB_COMPLETE_IDX = 0;
    const guint KEY = 0;

    keybindings_set_item(
            key_group,
            KB_COMPLETE_IDX,
            &force_completion,
            KEY,
            cast(GdkModifierType) 0,
            "exec",
            "complete",
            null // GtkWidget*
        );
}

extern(System) nothrow:

void force_completion(guint key_id)
{
    import geany_d_binding.document;
    import geany_d_binding.filetypes;
    import geany_d_binding.sciwrappers;
    import common.messages;

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
        {
            import geany_d_binding.dialogs;
            import gtkc.gtktypes: GtkMessageType;

            dialogs_show_msgbox(GtkMessageType.INFO, "%s", ret);
        }
    }
}

gboolean initPlugin(GeanyPlugin *plugin, gpointer pdata)
{
    geany_plugin = plugin;

    //~ {
        //~ import geany_d_binding.dialogs;
        //~ import gtkc.gtktypes: GtkMessageType;

        //~ dialogs_show_msgbox(GtkMessageType.INFO, "Hello, World!");
    //~ }

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
