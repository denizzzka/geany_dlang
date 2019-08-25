module geany_d_binding.geany.plugindata;

import geany_d_binding.geany.types;
import gtkc.gobjecttypes: GCallback;

enum GEANY_API_VERSION = 239;
private const ubyte GEANY_ABI_SHIFT;
const uint GEANY_ABI_VERSION;

shared static this()
{
    import gtk.Version;

    if(Version.checkVersion(3, 0, 0) is null)
        GEANY_ABI_SHIFT = 8;
    else
        GEANY_ABI_SHIFT = 0;

    enum __abi_macroversion = 72;

    GEANY_ABI_VERSION = __abi_macroversion << GEANY_ABI_SHIFT;
}

extern(System) @nogc nothrow:

import geany_d_binding.geany.app: GeanyApp;

/** This contains pointers to global variables owned by Geany for plugins to use.
 * Core variable pointers can be appended when needed by plugin authors, if appropriate. */
struct GeanyData
{
    GeanyApp				*app;				/**< Geany application data fields */
    GeanyMainWidgets		*main_widgets;		/**< Important widgets in the main window */
    GPtrArray					*documents_array;
    GPtrArray					*filetypes_array;
    GeanyPrefs			*prefs;				/**< General settings */
    GeanyInterfacePrefs	*interface_prefs;	/**< Interface settings */
    GeanyToolbarPrefs	*toolbar_prefs;		/**< Toolbar settings */
    GeanyEditorPrefs		*editor_prefs;		/**< Editor settings */
    GeanyFilePrefs		*file_prefs;		/**< File-related settings */
    GeanySearchPrefs		*search_prefs;		/**< Search-related settings */
    GeanyToolPrefs		*tool_prefs;		/**< Tool settings */
    GeanyTemplatePrefs	*template_prefs;	/**< Template settings */
    gpointer					*_compat;			/* Remove field on next ABI break (abi-todo) */
    GSList						*filetypes_by_title;
    GObject						*object;
}

struct GeanyMainWidgets;
struct GPtrArray;
struct GeanyPrefs;
struct GeanyInterfacePrefs;
struct GeanyToolbarPrefs;
struct GeanyEditorPrefs;
struct GeanyFilePrefs;
struct GeanySearchPrefs;
struct GeanyToolPrefs;
struct GeanyTemplatePrefs;
struct GSList; //TODO
struct GObject; //TODO

/** Callback array entry type used with the @ref plugin_callbacks symbol. */
struct PluginCallback
{
    /** The name of signal, must be an existing signal. For a list of available signals,
     *  please see the @link pluginsignals.c Signal documentation @endlink. */
    const(gchar)* signal_name;
    /** A callback function which is called when the signal is emitted. */
    GCallback   callback;
    /** Set to TRUE to connect your handler with g_signal_connect_after(). */
    gboolean    after;
    /** The user data passed to the signal handler. If set to NULL then the signal
     * handler will receive the data set with geany_plugin_register_full() or
     * geany_plugin_set_data() */
    gpointer    user_data;
}
