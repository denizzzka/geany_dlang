module dcd_wrapper;

import server.server;
import dsymbol.modulecache;
import logger;
import common.messages;
import common.messages: Request = AutocompleteRequest, Response = AutocompleteResponse;

class DcdWrapper
{
    package ModuleCache cache;

    this()
    {
        string[] importPaths = loadConfiguredImportDirs();

        cache = ModuleCache(new ASTAllocator);
        addImportPaths(importPaths);

        infof("Import directories:\n    %-(%s\n    %)", cache.getImportPaths());
        info(cache.symbolsAllocated, " symbols cached.");
    }

    void addImportPaths(string[] pathLines)
    {
        cache.addImportPaths(pathLines);
    }

    void clearCache()
    {
        info("Clearing cache.");
        cache.clear();
    }

    Response doRequest(Request request) nothrow
    {
        import server.autocomplete;
        import std.conv: to;

        nothrowLog!"info"("Do request. kind = "~request.kind.to!string);

        Response ret;

        try
        {
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
                        nothrowLog!"warning"("Could not get DDoc information: "~e.msg);

                    break;

                case symbolLocation:
                    try
                        ret = findDeclaration(request, cache);
                    catch (Exception e)
                        nothrowLog!"warning"("Could not get symbol location: "~e.msg);

                    break;

                case search:
                    ret = symbolSearch(request, cache);
                    break;

                case localUse:
                    try
                        ret = findLocalUse(request, cache);
                    catch (Exception e)
                        nothrowLog!"warning"("Could not find local usage: "~e.msg);

                    break;

                default:
                    assert(false, "Unsupported request kind");
            }
        }
        catch(Exception e)
        {
            nothrowLog!"warning"(e.msg);
        }

        return ret;
    }
}
