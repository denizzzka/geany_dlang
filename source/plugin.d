version(IntegrationTest){} else:

import geany_d_binding.geany.plugins;
import geany_d_binding.geany.types;
import dcd_wrapper;
import logger;
import geany_d_binding.geany.sciwrappers;
import std.conv: to;
import dcd.common.messages;
import geany_d_binding.geany.document;
import geany_d_binding.geany.filetypes;
import geany_d_binding.scintilla.types;
import geany_d_binding.scintilla.Scintilla;
import geany_d_binding.scintilla.ScintillaGTK;
import std.string: toStringz;

private GeanyPlugin* geany_plugin;
private DcdWrapper wrapper;

void init_keybindings() nothrow
{
    import geany_d_binding.geany.pluginutils;
    import geany_d_binding.geany.keybindings;
    import gdk.Gdk: GdkModifierType;
    import gtk.Widget: GtkWidget;

    const gsize COUNT_KB = 2;

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
            "Complete code",
            null // GtkWidget*
        );


    keybindings_set_item(
            key_group,
            1,
            &show_debug,
            KEY,
            cast(GdkModifierType) 0,
            "exec 2",
            "Dump debug info into console",
            null // GtkWidget*
        );
}

void addCurrDocumentDirIntoImport(GeanyDocument* doc) nothrow
{
    nothrowLog!"trace"(__FUNCTION__);

    if(doc != null && doc.file_type.id == GeanyFiletypeID.GEANY_FILETYPES_D)
    {
        import std.path;

        string filename = doc.file_name.to!string;
        string path = dirName(filename);

        try
        {
            nothrowLog!"trace"("Begin adding import path "~path);

            wrapper.addImportPaths([path.to!string]);
        }
        catch(Exception e)
            nothrowLog!"warning"(e.msg);
    }
}

void attemptDisplaySomeWindow() nothrow
{
    GeanyDocument* doc = document_get_current();
    const res = calculateCompletion(doc);

    if(res.completions.length > 0)
    {
        const currPos = doc.editor.sci.sci_get_current_position;

        const separator = cast(char) scintilla_send_message(
                doc.editor.sci,
                Sci.SCI_AUTOCGETSEPARATOR,
                null,
                null
            );

        with(CompletionType)
        switch(res.completionType)
        {
            case identifiers:
                attemptDisplayCompletionWindow(doc, res, separator, currPos);
                break;

            case calltips:
                attemptDisplayTipWindow(doc, res, separator, currPos);
                break;

            default:
                nothrowLog!"warning"("Unknown completionType "~res.completionType.to!string);
                break;
        }
    }
}

void attemptDisplayCompletionWindow(GeanyDocument* doc, in AutocompleteResponse res, char separator, int currPos) nothrow
{
    const wordStartPos = cast(size_t) scintilla_send_message(
            doc.editor.sci,
            Sci.SCI_WORDSTARTPOSITION,
            cast(uptr_t) currPos,
            cast(sptr_t) true
        );

    string preparedList;

    foreach(i, ref c; res.completions)
    {
        if(i != 0)
            preparedList ~= separator;

        preparedList ~= c.identifier;

        switch(c.kind)
        {
            case 'k':
                preparedList ~= "?1";
                break;

            case 'v':
                preparedList ~= "?2";
                break;

            default:
                break;
        }
    }

    scintilla_send_message(
            doc.editor.sci,
            Sci.SCI_AUTOCSETORDER,
            cast(uptr_t) Sc.SC_ORDER_PERFORMSORT,
            null
        );

    const size_t alreadyEnteredNum = currPos - wordStartPos;
    nothrowLog!"trace"("alreadyEnteredNum="~alreadyEnteredNum.to!string);

    scintilla_send_message(
            doc.editor.sci,
            Sci.SCI_AUTOCSHOW,
            cast(uptr_t) alreadyEnteredNum,
            cast(sptr_t) preparedList.toStringz
        );
}

void attemptDisplayTipWindow(GeanyDocument* doc, in AutocompleteResponse tips, char separator, int pos) nothrow
{
    string str;

    foreach(i, ref c; tips.completions)
    {
        if(i != 0)
            str ~= separator;

        str ~= c.definition;
    }

    scintilla_send_message(
            doc.editor.sci,
            Sci.SCI_CALLTIPSHOW,
            cast(uptr_t) pos,
            cast(sptr_t) str.toStringz
        );
}

AutocompleteResponse calculateCompletion(GeanyDocument* doc) nothrow
{
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

gboolean on_editor_notify(GObject* object, GeanyEditor* editor, SCNotification* nt, gpointer data)
{
    import geany_d_binding.geany.dialogs;
    import gtkc.gtktypes: GtkMessageType;

    with(Msg)
    switch (nt.nmhdr.code)
    {
        case SCN_CHARADDED:
            nothrowLog!"trace"("SCN_CHARADDED received");
            attemptDisplaySomeWindow();
            break;
            //~ return true;

        case SCN_KEY:
        case SCN_UPDATEUI:
        case SCN_MODIFIED:
        case SCN_PAINTED:
        case SCN_FOCUSIN:
        case SCN_FOCUSOUT:
        case SCN_ZOOM:
            break;

        default:
            auto c = cast(Msg) nt.nmhdr.code;
            nothrowLog!"trace"("Notify code="~c.to!string);
            break;
    }

    return false;
}

void on_document_filetype_set(GObject* obj, GeanyDocument* doc, GeanyFiletype* filetype_old, gpointer user_data)
{
    nothrowLog!"trace"(__FUNCTION__);

    addCurrDocumentDirIntoImport(doc);
}

void show_debug(guint key_id)
{
    nothrowLog!"info"(
        "Import paths:\n"~wrapper.listImportPaths.to!string
    );
}

void force_completion(guint key_id)
{
    attemptDisplaySomeWindow();
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
        PluginCallback("document-filetype-set", cast(GCallback) &on_document_filetype_set, true, null),
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
    plugin.info._version = "0.x.x"; //TODO: fill out automatically
    plugin.info.author = "Denis Feklushkin <denis.feklushkin@gmail.com>";

    try
        GEANY_PLUGIN_REGISTER(plugin, 225);
    catch(Exception e)
        nothrowLog!"fatal"(e.msg);
}
