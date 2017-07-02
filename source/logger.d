module logger;

public import std.experimental.logger;

void nothrowLog
(
    string S,
    int line = __LINE__,
    string file = __FILE__,
    string funcName = __FUNCTION__,
    string prettyFuncName = __PRETTY_FUNCTION__,
    string moduleName = __MODULE__,
    A...
)
(lazy string msg) nothrow
{
    import std.experimental.logger;

    try
    {
        static if(S == "trace")
            trace!(line, file, funcName, prettyFuncName, moduleName)(msg);
        else static if(S == "info")
            info!(line, file, funcName, prettyFuncName, moduleName)(msg);
        else static if(S == "warning")
            warning!(line, file, funcName, prettyFuncName, moduleName)(msg);
        else static if(S == "error")
            error!(line, file, funcName, prettyFuncName, moduleName)(msg);
        else static if(S == "fatal")
            fatal!(line, file, funcName, prettyFuncName, moduleName)(msg);
        else
            static assert(false, "Unsupported log type");
    }
    catch(Exception e)
    {
        // TODO: pass error to unthrowable geany logger
        assert(false);
    }
}
