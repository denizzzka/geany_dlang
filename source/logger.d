module logger;

import glib.c.types: GLogLevelFlags;
import std.exception: assumeWontThrow;

private void logv(GLogLevelFlags logLevel, string msg, string file, size_t line) nothrow @trusted
{
    import glib.MessageLog;
    import std.conv: to;

    assumeWontThrow( // TODO: logv need to be changed?
        MessageLog.logv(null, logLevel, file~':'~line.to!string~':'~msg, null)
    );
}

void nothrowLog
(
    string S,
)
(lazy string msg, string file = __FILE__, size_t line = __LINE__) nothrow
{
    static if(S == "trace")
        enum flags = GLogLevelFlags.LEVEL_DEBUG;
    else static if(S == "info")
        enum flags = GLogLevelFlags.LEVEL_INFO;
    else static if(S == "warning")
        enum flags = GLogLevelFlags.LEVEL_WARNING;
    else static if(S == "error")
        enum flags = GLogLevelFlags.LEVEL_ERROR;
    else static if(S == "fatal")
        enum flags = GLogLevelFlags.LEVEL_CRITICAL;
    else
        static assert(false, "Unsupported log type "~S);

    try
    {
        logv(flags, msg, file, line);
    }
    catch(Exception e)
    {
        // TODO: pass error to unthrowable geany logger
        assert(false);
    }
}

void nothrowLog
(
    string S,
)
(Exception e) nothrow
{
    import std.conv: to;

    static if(S == "warning")
        enum flags = GLogLevelFlags.LEVEL_WARNING;
    else static if(S == "error")
        enum flags = GLogLevelFlags.LEVEL_ERROR;
    else static if(S == "fatal")
        enum flags = GLogLevelFlags.LEVEL_CRITICAL;
    else
        static assert(false, "Unsupported log type "~S);

    try
    {
        logv(flags, assumeWontThrow(e.to!string), e.file, e.line);
    }
    catch(Exception e)
    {
        // TODO: pass error to unthrowable geany logger
        assert(false);
    }
}
