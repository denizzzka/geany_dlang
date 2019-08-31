module geany_dlang.dcd_wrapper;

import dcd.server.server;
import dsymbol.modulecache;
import logger;
import dcd.common.messages;
import dcd.common.messages: Request = AutocompleteRequest, Response = AutocompleteResponse;

class DcdWrapper
{
    package ModuleCache cache;

    this()
    {
        cache = ModuleCache(new ASTAllocator);
    }

    static string[] loadConfiguredImportDirs() @trusted
    {
        return dcd.server.server.loadConfiguredImportDirs();
    }

    void addImportPaths(string[] pathLines)
    {
        cache.addImportPaths(pathLines);
    }

    void removeImportPaths(in string[] pathLines)
    {
        cache.removeImportPaths(pathLines);
    }

    string listImportPaths()
    {
        auto g = cache.getImportPaths();
        string ret;

        foreach(s; g)
            ret ~= s~"\n";

        return ret;
    }

    void clearCache()
    {
        info("Clearing cache.");
        cache.clear();
    }

    Response doRequest(Request request) nothrow
    {
        import dcd.server.autocomplete;
        import std.conv: to;
        import std.exception;

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
                    throw new Exception("Unsupported request kind");
            }
        }
        catch(Exception e)
        {
            nothrowLog!"warning"(e.msg);
        }

        return ret;
    }
}
