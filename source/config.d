module geany_dlang.config;

@safe:

import dyaml;

struct Config
{
    bool useCharAddEvent;
    string[] addtitionalPaths;
}

import geany_d_binding.geany.plugins: GeanyData; 

Config establishCfg(in GeanyData* geany_data)
{
    import std.path;
    import std.file;

    const dir = buildPath(geany_data.app.configdir, "plugins", "dlang_plugin");
    dir.mkdirRecurse;

    const filepath = buildPath(dir, "dlang_plugin.conf");

    Config ret;

    if(!filepath.exists)
    {
        filepath.write("AAAAA bbb ccc");
    }

    return filepath.loadConf;
}

private Config loadConf(string filename) {
    import std.file;
    import std.conv;

    auto buf = /*cast(ubyte[])*/ readText(filename);

    Config ret;

    Loader.fromBuffer(buf).load.deserializeInto(ret);

    return ret;
}
