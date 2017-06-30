module dcd_wrapper;

import server.server;
import dsymbol.modulecache;
import std.experimental.logger;

const string[] importPaths;

static this()
{
    importPaths = loadConfiguredImportDirs();
}

class DcdWrapper
{
    package ModuleCache cache;

    this()
    {
        cache = ModuleCache(new ASTAllocator);
        cache.addImportPaths(importPaths);

        infof("Import directories:\n    %-(%s\n    %)", cache.getImportPaths());
        info(cache.symbolsAllocated, " symbols cached.");
    }
}
