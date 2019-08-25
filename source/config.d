module geany_dlang.config;

@safe:

struct Config
{
    bool useCharAddEvent;
    string[] addtitionalPaths;
}

import geany_d_binding.geany.plugindata: GeanyData; 

Config establishCfg(in GeanyData* geany_data)
{
    import std.path;
    import std.file;
    import std.conv: to;

    string confDir;

    () @trusted { confDir = geany_data.app.configdir.to!string; }();

    const dir = buildPath(confDir, "plugins", "dlang_plugin");
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
    import dyaml;
    import yamlserialized;

    auto buf = readText(filename).to!(ubyte[]);

    Config ret;

    Loader.fromBuffer(buf).load().deserializeInto(ret);

    return ret;
}
