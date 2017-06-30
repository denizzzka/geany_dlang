version(IntegrationTest){} else:

import geany_plugin_d_api;
import dcd_wrapper;

enum serverStart = "dub run dcd --build=release --config=server";
DcdWrapper wrapper;

extern(System):

gboolean initPlugin(GeanyPlugin *plugin, gpointer pdata)
{
    wrapper = new DcdWrapper();

    return true;
}

void cleanupPlugin(GeanyPlugin *plugin, gpointer pdata)
{
    destroy(wrapper);
}

void geany_load_module(GeanyPlugin *plugin)
{
    plugin.funcs._init = &initPlugin;
    plugin.funcs.cleanup = &cleanupPlugin;

    plugin.info.name = "D language";
    plugin.info.description = "Adds D language support";
    plugin.info._version = "0.0.1";
    plugin.info.author = "Denis Feklushkin <denis.feklushkin@gmail.com>";

    if (GEANY_PLUGIN_REGISTER(plugin, 225))
        return;
}
