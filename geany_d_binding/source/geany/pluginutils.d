module geany_d_binding.geany.pluginutils;

import geany_d_binding.geany.plugins: GeanyPlugin;
import geany_d_binding.geany.types;
import geany_d_binding.geany.keybindings;

extern(System) @nogc nothrow:

GeanyKeyGroup* plugin_set_key_group(GeanyPlugin* plugin, const(gchar)* section_name, gsize count, GeanyKeyGroupCallback callback);
