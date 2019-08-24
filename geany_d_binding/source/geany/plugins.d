module geany_d_binding.geany.plugins;

import geany_d_binding.geany.types;
import geany_d_binding.geany.plugindata: GEANY_API_VERSION, GEANY_ABI_VERSION;
import gtkc.gobjecttypes: GCallback;
import gtkc.gtktypes: GtkDialog, GtkWidget, GDestroyNotify;
import glib.c.types: GModule;

extern(System) @nogc nothrow
{
    /** Basic information about a plugin available to Geany without loading the plugin. */
    struct PluginInfo
    {
        /** The name of the plugin. */
        const(gchar)* name;
        /** The description of the plugin. */
        const(gchar)* description;
        /** The version of the plugin. */
        const(gchar)* _version;
        /** The author of the plugin. */
        const(gchar)* author;
    }

    /** Basic information for the plugin and identification. */
    struct GeanyPlugin
    {
        PluginInfo* info;  /**< Fields set in plugin_set_info(). */
        GeanyData*  geany_data;     /**< Pointer to global GeanyData intance */
        GeanyPluginFuncs* funcs;    /**< Functions implemented by the plugin, set in geany_load_module() */
        GeanyProxyFuncs*  proxy_funcs; /**< Hooks implemented by the plugin if it wants to act as a proxy
                                            Must be set prior to calling geany_plugin_register_proxy() */
        private GeanyPluginPrivate* priv;    /* private */
    }

    /** Callback functions that need to be implemented for every plugin. */
    struct GeanyPluginFuncs
    {
        /** Array of plugin-provided signal handlers @see PluginCallback */
        PluginCallback* callbacks;
        /** Called to initialize the plugin, when the user activates it (must not be @c NULL) */
        gboolean function(GeanyPlugin* plugin, gpointer pdata) _init;
        /** plugins configure dialog, optional (can be @c NULL) */
        GtkWidget* function(GeanyPlugin* plugin, GtkDialog* dialog, gpointer pdata) configure;
        /** Called when the plugin should show some help, optional (can be @c NULL) */
        void function(GeanyPlugin* plugin, gpointer pdata) help;
        /** Called when the plugin is disabled or when Geany exits (must not be @c NULL) */
        void function(GeanyPlugin* p, gpointer pdata) cleanup;
    }

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

    struct GeanyData;
    struct GeanyProxyFuncs;
    struct GeanyPluginPrivate;

    gboolean geany_plugin_register(GeanyPlugin* plugin, gint api_version,
                                   gint min_api_version, gint abi_version);

    gboolean geany_plugin_register_full(GeanyPlugin* plugin, gint api_version,
                                        gint min_api_version, gint abi_version,
                                        gpointer data, GDestroyNotify free_func);
}

extern(System) export const(gchar)* g_module_check_init(GModule* modul)
{
    import core.runtime: Runtime;

    Runtime.initialize(); //TODO: result check

    return null;
}

extern(System) export void g_module_unload(GModule* modul)
{
    import core.runtime: Runtime;

    Runtime.terminate(); //TODO: result check
}

/// It is need to implement it in the plugin code
extern(System) export void geany_load_module(GeanyPlugin *plugin) nothrow;

gboolean GEANY_PLUGIN_REGISTER(GeanyPlugin* plugin, gint min_api_version)
{
    return geany_plugin_register(plugin, GEANY_API_VERSION, min_api_version, GEANY_ABI_VERSION);
}

gboolean GEANY_PLUGIN_REGISTER_FULL(GeanyPlugin* plugin, gint min_api_version, gpointer pdata, GDestroyNotify free_func)
{
    return geany_plugin_register_full(plugin, GEANY_API_VERSION, min_api_version, GEANY_ABI_VERSION, pdata, free_func);
}
