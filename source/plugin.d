version(IntegrationTest){} else:

import geany_d_binding.geany;
import dcd_wrapper;
import logger;

enum serverStart = "dub run dcd --build=release --config=server";
private GeanyPlugin* geany_plugin;
private DcdWrapper wrapper;

void init_keybindings() nothrow
{
    import geany_d_binding.geany.pluginutils;
    import geany_d_binding.geany.keybindings;
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

import gtkc.gobjecttypes: GObject;
import geany_d_binding.geany.editor: GeanyEditor;
import geany_d_binding.scintilla.Scintilla: SCNotification, Msg;

gboolean on_editor_notify(GObject *object, GeanyEditor *editor, SCNotification *nt, gpointer data)
{
    import geany_d_binding.geany.dialogs;
    import gtkc.gtktypes: GtkMessageType;
    import std.conv: to;

    with(Msg)
    switch (nt.nmhdr.code)
    {
        case SCI_AUTOCSHOW:
        case SCI_USERLISTSHOW:
            dialogs_show_msgbox(GtkMessageType.INFO, "Catched!");
            break;

        case SCN_CHARADDED:
        case SCN_KEY:
        case SCN_UPDATEUI:
        case SCN_MODIFIED:
        case SCN_PAINTED:
        case SCN_FOCUSIN:
        case SCN_FOCUSOUT:
            break;

        default:
            auto c = cast(Msg) nt.nmhdr.code;
            nothrowLog!"trace"("Notify code="~c.to!string);
            //~ nothrowLog!"trace"("Notify code="~nt.nmhdr.code.to!string);
            break;
    }

    return false;
}

void force_completion(guint key_id)
{
    import geany_d_binding.geany.document;
    import geany_d_binding.geany.filetypes;
    import geany_d_binding.geany.sciwrappers;
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
        try
        {
            import geany_d_binding.geany.dialogs;
            import gtkc.gtktypes: GtkMessageType;

            import std.format;
            import std.string;
            auto s = format("pos=%d, searchName=%s\n%s", req.cursorPosition, req.searchName, ret);
            dialogs_show_msgbox(GtkMessageType.INFO, s.toStringz);
        }
        catch(Exception e)
        {
            nothrowLog!"error"(e.msg);
        }
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

    init_keybindings();

    return true;
}

void cleanupPlugin(GeanyPlugin *plugin, gpointer pdata)
{
    try
        destroy(wrapper);
    catch(Exception e)
        nothrowLog!"fatal"(e.msg);
}

private PluginCallback[] callbacks;

shared static this()
{
    import gtkc.gobjecttypes: GCallback;

    callbacks =
    [
        PluginCallback("editor-notify", cast(GCallback) &on_editor_notify, false, null),
        PluginCallback(null, null, false, null)
    ];
}

void geany_load_module(GeanyPlugin *plugin)
{
    plugin.funcs._init = &initPlugin;
    plugin.funcs.cleanup = &cleanupPlugin;
    plugin.funcs.callbacks = &callbacks[0];

    plugin.info.name = "D language";
    plugin.info.description = "Adds D language support";
    plugin.info._version = "0.0.1";
    plugin.info.author = "Denis Feklushkin <denis.feklushkin@gmail.com>";

    try
        GEANY_PLUGIN_REGISTER(plugin, 225);
    catch(Exception e)
        nothrowLog!"fatal"(e.msg);
}
