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
    this()
    {
        ModuleCache cache = ModuleCache(new ASTAllocator);
        cache.addImportPaths(importPaths);
        //~ infof("Import directories:\n    %-(%s\n    %)", cache.getImportPaths());
    }
}
