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

import common.messages;
import geany_d_binding.geany.document;

void completionAttempt() nothrow
{
    import geany_d_binding.scintilla.types;
    import geany_d_binding.scintilla.Scintilla;
    import geany_d_binding.scintilla.ScintillaGTK;
    import std.string;

    GeanyDocument* doc = document_get_current();
    const res = calculateCompletion(doc);

    if(res.completions.length > 0)
    {
        const int separator = cast(char) scintilla_send_message(
                doc.editor.sci,
                Sci.SCI_AUTOCGETSEPARATOR,
                null,
                null
            );

        string preparedList;

        foreach(i, ref c; res.completions)
        {
            if(i != 0)
                preparedList ~= separator;

            preparedList ~= c;
        }

        auto wasSort = scintilla_send_message(
                doc.editor.sci,
                Sci.SCI_AUTOCGETORDER,
                cast(uptr_t) Sc.SC_ORDER_PERFORMSORT,
                null
            );

        nothrowLog!"trace"("scintilla_send_message");
        scintilla_send_message(
                doc.editor.sci,
                Sci.SCI_AUTOCSHOW,
                null, //FIXME: number of characters of the word already entered
                cast(sptr_t) preparedList.toStringz
            );

        scintilla_send_message(
                doc.editor.sci,
                Sci.SCI_AUTOCSETORDER,
                cast(uptr_t) wasSort,
                null
            );
    }
}

AutocompleteResponse calculateCompletion(GeanyDocument* doc) nothrow
{
    import geany_d_binding.geany.filetypes;
    import geany_d_binding.geany.sciwrappers;

    AutocompleteResponse ret;

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

        ret = wrapper.doRequest(req);
    }

    return ret;
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
        case SCN_CHARADDED:
            nothrowLog!"trace"("SCN_CHARADDED received");
            completionAttempt();
            break;
            //~ return true;

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
            break;
    }

    return false;
}

void force_completion(guint key_id)
{
    import geany_d_binding.geany.filetypes;
    import geany_d_binding.geany.sciwrappers;

    GeanyDocument* doc = document_get_current();
    auto ret = calculateCompletion(doc);

    try
    {
        import geany_d_binding.geany.dialogs;
        import gtkc.gtktypes: GtkMessageType;

        import std.format;
        import std.string;
        auto s = format("%s", ret);
        dialogs_show_msgbox(GtkMessageType.INFO, s.toStringz);
    }
    catch(Exception e)
    {
        nothrowLog!"error"(e.msg);
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
