module dcd_wrapper;

import server.server;
import dsymbol.modulecache;
import std.experimental.logger;
import common.messages;
import common.messages: Request = AutocompleteRequest, Response = AutocompleteResponse;

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

    const(string)[] listImports() const
    {
        return importPaths;
    }

    void clearCache()
    {
        info("Clearing cache.");
        cache.clear();
    }

    Response doRequest(Request request)
    {
        import server.autocomplete;
        import std.conv: to;

        info("Do request, kind is ", request.kind.to!string);

        Response ret;

        with(RequestKind)
        switch(request.kind)
        {
            case autocomplete:
                ret = complete(request, cache);
                break;

            case doc:
                try
                    ret = getDoc(request, cache);
                catch (Exception e)
                    warning("Could not get DDoc information", e.msg);

                break;

            case symbolLocation:
                try
                    ret = findDeclaration(request, cache);
                catch (Exception e)
                    warning("Could not get symbol location", e.msg);

                break;

            case search:
                ret = symbolSearch(request, cache);
                break;

            case localUse:
                try
                    ret = findLocalUse(request, cache);
                catch (Exception e)
                    warning("Could not find local usage", e.msg);

                break;

            default:
                assert(false, "Unsupported request kind");
        }

        return ret;
    }
}
