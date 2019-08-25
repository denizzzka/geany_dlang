module geany_dlang.config;

import logger;
import std.file;
import std.conv;
import dyaml;
import yamlserialized;

@safe:

struct Config
{
    bool useCharAddEvent;
    string[] addtitionalPaths;
}

import geany_d_binding.geany.plugindata: GeanyData; 

class ConfigFile
{
    private string filepath;
    Config config;

    this(in GeanyData* geany_data)
    {
        import std.path;

        string confDir;

        () @trusted { confDir = geany_data.app.configdir.to!string; }();

        const dir = buildPath(confDir, "plugins", "dlang_plugin");
        dir.mkdirRecurse;

        filepath = buildPath(dir, "dlang_plugin.conf");

        nothrowLog!"info"("Config file is "~filepath);

        if(!filepath.exists)
        {
            filepath.append(""); // creates empty config file
            config = Config(); // default config will be used
        }
        else
        {
            config = filepath.loadConf;
        }
    }

    ~this()
    {
        saveConf();
    }

    void saveConf()
    {
        import std.stdio: File;

        auto root = config.toYAMLNode;

        auto dumper = dumper();
        dumper.dump(File(filepath, "w").lockingTextWriter, root);
    }
}

private Config loadConf(string filename)
{
    ubyte[] buf;

    () @trusted { buf = cast(ubyte[]) readText(filename); }();

    Config ret;

    Loader.fromBuffer(buf).load().deserializeInto(ret);

    return ret;
}
