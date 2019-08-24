import geany_d_binding.geany.plugins;
import geany_d_binding.geany.types;
import glib.c.types: GModule;
//~ import std.stdio: writeln;

extern(System):

gboolean hello_init(GeanyPlugin* plugin, gpointer pdata)
{
    //~ writeln("Hello World from D plugin!\n");
    /* Perform advanced set up here */
    return true;
}

void hello_cleanup(GeanyPlugin* plugin, gpointer pdata)
{
    //~ writeln("Bye, World!\n");
}

void geany_load_module(GeanyPlugin* plugin)
{
    /* Step 1: Set metadata */
    plugin.info.name = "D HelloWorld";
    plugin.info.description = "D plugin example";
    plugin.info._version = "1.0";
    plugin.info.author = "John Doe <john.doe@example.org>";

    /* Step 2: Set functions */
    plugin.funcs._init = &hello_init;
    plugin.funcs.cleanup = &hello_cleanup;

    /* Step 3: Register! */
    if (GEANY_PLUGIN_REGISTER(plugin, 225))
        return;
    /* alternatively:
    GEANY_PLUGIN_REGISTER_FULL(plugin, 225, data, free_func); */
}
