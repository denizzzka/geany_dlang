module dcd_wrapper;

import server.server;
import dsymbol.modulecache;

const string[] importPaths;

static this()
{
    importPaths = loadConfiguredImportDirs();
}

class DcdWrapper
{
    private ModuleCache cache;

    this()
    {
        cache = ModuleCache(new ASTAllocator);
        cache.addImportPaths(importPaths);
    }
}
